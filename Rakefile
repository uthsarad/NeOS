# frozen_string_literal: true

require_relative 'tools/neos_tasks'

desc 'Verify profile auditing ownership (canonical auditor: tools/neos-profile-audit)'
task :audit do
  Neos::Tasks.audit_ownership_guard
end

namespace :manifest do
  desc 'Regenerate Calamares netinstall and overlay manifests'
  task :generate do
    Neos::Tasks.generate_manifests
  end
end

namespace :test do
  desc 'Run full verification test suite'
  task :all do
    Neos::Tasks.run_tests
  end

  desc 'Run Ruby unit tests'
  task :ruby do
    ruby '-Ilib:test', '-e', "%w[minitest/autorun].each { |f| require f }; Dir.glob('./tests/ruby/test_*.rb').each { |f| require f }"
  end
end

desc 'Run full audit and verification test pipeline'
task default: %i[audit test:ruby test:all]
