# frozen_string_literal: true

require 'fileutils'
require 'set'

module Neos
  module Tasks
    VERSION = '2026.11.14'

    class << self
      # Profile auditing was consolidated into tools/neos-profile-audit (Rust).
      # The former Ruby duplicate (audit_profile) is gone; this guard keeps the
      # Rakefile contract intact and fails if the duplicate is re-introduced.
      def audit_ownership_guard(root_dir = '.')
        rust_main = File.join(root_dir, 'tools/neos-profile-audit/src/main.rs')
        raise 'tools/neos-profile-audit/src/main.rs is missing — the canonical NeOS profile auditor' unless File.exist?(rust_main)
        raise 'Duplicate Ruby profile audit re-introduced: audit_profile must stay removed (owned by tools/neos-profile-audit)' if method_defined?(:audit_profile) || respond_to?(:audit_profile)

        puts "\e[1;32m✓ Profile auditing owned by tools/neos-profile-audit (Rust) — single source of truth confirmed\e[0m"
        true
      end

      def generate_manifests(root_dir = '.')
        puts "\e[1;36m[Ruby::Manifest]\e[0m Regenerating netinstall manifests..."
        # Pass argv array directly so root_dir is never parsed by /bin/sh (CWE-78).
        script = File.join(root_dir, 'tools/gen-manifests.sh')
        system('bash', script, root_dir) || raise('Failed to generate manifests')
      end

      def run_tests(root_dir = '.')
        puts "\e[1;36m[Ruby::TestRunner]\e[0m Executing NeOS verification suite..."
        test_scripts = Dir.glob(File.join(root_dir, 'tests/verify_*.sh')).sort
        failed = []

        test_scripts.each do |script|
          name = File.basename(script)
          if %w[verify_iso_calamares_libs.sh verify_iso_smoketest.sh].include?(name)
            puts "  • Skipping #{name} (requires built ISO)"
            next
          end
          print "  • Running #{name}... "
          if system('bash', script, out: File::NULL, err: File::NULL)
            puts "\e[1;32mPASSED\e[0m"
          else
            puts "\e[1;31mFAILED\e[0m"
            failed << name
          end
        end

        if failed.empty?
          puts "\e[1;32m✓ All #{test_scripts.size} tests passed flawlessly!\e[0m"
          true
        else
          raise "The following tests failed: #{failed.join(', ')}"
        end
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  case ARGV[0]
  when 'audit'
    Neos::Tasks.audit_ownership_guard(ARGV[1] || '.')
  when 'manifest'
    Neos::Tasks.generate_manifests(ARGV[1] || '.')
  when 'test'
    Neos::Tasks.run_tests(ARGV[1] || '.')
  else
    puts "Usage: ruby tools/neos_tasks.rb [audit|manifest|test]\n  (audit verifies the canonical Rust auditor in tools/neos-profile-audit)"
  end
end
