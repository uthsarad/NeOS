require 'minitest/autorun'
require 'stringio'
require 'tmpdir'
require 'fileutils'
require_relative '../../tools/neos_tasks.rb'

class TestNeosTasks < Minitest::Test
  def setup
    @original_stdout = $stdout
    $stdout = StringIO.new
  end

  def teardown
    $stdout = @original_stdout
  end

  def test_audit_ownership_guard_success
    Dir.mktmpdir do |dir|
      rust_dir = File.join(dir, 'tools/neos-profile-audit/src')
      FileUtils.mkdir_p(rust_dir)
      File.write(File.join(rust_dir, 'main.rs'), '// stub')
      assert_equal true, Neos::Tasks.audit_ownership_guard(dir)
    end
  end

  def test_audit_ownership_guard_missing_rust_file
    Dir.mktmpdir do |dir|
      err = assert_raises(RuntimeError) do
        Neos::Tasks.audit_ownership_guard(dir)
      end
      assert_equal 'tools/neos-profile-audit/src/main.rs is missing — the canonical NeOS profile auditor', err.message
    end
  end

  def test_audit_ownership_guard_duplicate_ruby_method
    Dir.mktmpdir do |dir|
      rust_dir = File.join(dir, 'tools/neos-profile-audit/src')
      FileUtils.mkdir_p(rust_dir)
      File.write(File.join(rust_dir, 'main.rs'), '// stub')
      Neos::Tasks.singleton_class.class_eval do
        def audit_profile; end
      end

      begin
        err = assert_raises(RuntimeError) do
          Neos::Tasks.audit_ownership_guard(dir)
        end
        assert_equal 'Duplicate Ruby profile audit re-introduced: audit_profile must stay removed (owned by tools/neos-profile-audit)', err.message
      ensure
        Neos::Tasks.singleton_class.class_eval do
          remove_method :audit_profile
        end
      end
    end
  end

  def test_generate_manifests_does_not_shell_eval_root_dir
    Dir.mktmpdir do |dir|
      marker = File.join(dir, 'injected')
      malicious_root = "#{dir}/sub; touch #{marker}"
      assert_raises(RuntimeError) do
        Neos::Tasks.generate_manifests(malicious_root)
      end
      refute File.exist?(marker), 'root_dir must not be evaluated by /bin/sh'
    end
  end
end
