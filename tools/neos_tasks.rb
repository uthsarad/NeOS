# frozen_string_literal: true

require 'open-uri'
require 'fileutils'
require 'set'

module Neos
  module Tasks
    VERSION = '2026.08.18'

    class << self
      def audit_profile(root_dir = '.')
        puts "\e[1;36m[Ruby::Audit]\e[0m Auditing archiso profile at: #{root_dir}"
        
        required_files = %w[
          profile/profiledef.sh
          profile/pacman.conf
          profile/grub/grub.cfg
          profile/syslinux/syslinux.cfg
          profile/packages.x86_64
          profile/airootfs/etc/pacman.d/neos-mirrorlist
          profile/airootfs/etc/pacman.d/chaotic-mirrorlist
        ]

        missing = required_files.reject { |f| File.exist?(File.join(root_dir, f)) }
        unless missing.empty?
          raise "Missing required profile files: #{missing.join(', ')}"
        end

        packages = File.readlines(File.join(root_dir, 'profile/packages.x86_64'))
                       .map(&:strip)
                       .reject { |l| l.empty? || l.start_with?('#') }

        duplicates = packages.select { |p| packages.count(p) > 1 }.uniq
        raise "Duplicate packages found: #{duplicates.join(', ')}" unless duplicates.empty?

        required_pkgs = %w[base mkinitcpio mkinitcpio-archiso networkmanager sudo vim]
        missing_pkgs = required_pkgs.reject { |p| packages.include?(p) }
        raise "Missing required packages: #{missing_pkgs.join(', ')}" unless missing_pkgs.empty?

        puts "\e[1;32m✓ Profile audit passed successfully! (#{packages.size} unique packages)\e[0m"
        true
      end

      def generate_manifests(root_dir = '.')
        puts "\e[1;36m[Ruby::Manifest]\e[0m Regenerating netinstall manifests..."
        system("bash tools/gen-manifests.sh #{root_dir}") || raise("Failed to generate manifests")
      end

      def run_tests(root_dir = '.')
        puts "\e[1;36m[Ruby::TestRunner]\e[0m Executing NeOS verification suite..."
        test_scripts = Dir.glob(File.join(root_dir, 'tests/verify_*.sh')).sort
        failed = []

        test_scripts.each do |script|
          name = File.basename(script)
          print "  • Running #{name}... "
          if system("bash #{script} > /dev/null 2>&1")
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
    Neos::Tasks.audit_profile(ARGV[1] || '.')
  when 'manifest'
    Neos::Tasks.generate_manifests(ARGV[1] || '.')
  when 'test'
    Neos::Tasks.run_tests(ARGV[1] || '.')
  else
    puts "Usage: ruby tools/neos_tasks.rb [audit|manifest|test]"
  end
end
