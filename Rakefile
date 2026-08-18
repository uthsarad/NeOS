# frozen_string_literal: true

require_relative 'tools/neos_tasks'

desc 'Audit NeOS archiso profile hygiene'
task :audit do
  Neos::Tasks.audit_profile
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
end

desc 'Run full audit and verification test pipeline'
task default: %i[audit test:all]
