require 'minitest/autorun'
require 'minitest/mock'
require 'stringio'
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
    original_exist = File.method(:exist?)
    File.stub :exist?, proc { |path| path == File.join('.', 'tools/neos-profile-audit/src/main.rs') ? true : original_exist.call(path) } do
      assert_equal true, Neos::Tasks.audit_ownership_guard
    end
  end

  def test_audit_ownership_guard_missing_rust_file
    original_exist = File.method(:exist?)
    File.stub :exist?, proc { |path| path == File.join('.', 'tools/neos-profile-audit/src/main.rs') ? false : original_exist.call(path) } do
      err = assert_raises(RuntimeError) do
        Neos::Tasks.audit_ownership_guard
      end
      assert_equal 'tools/neos-profile-audit/src/main.rs is missing — the canonical NeOS profile auditor', err.message
    end
  end

  def test_audit_ownership_guard_duplicate_ruby_method
    original_exist = File.method(:exist?)
    File.stub :exist?, proc { |path| path == File.join('.', 'tools/neos-profile-audit/src/main.rs') ? true : original_exist.call(path) } do
      Neos::Tasks.singleton_class.class_eval do
        def audit_profile; end
      end

      begin
        err = assert_raises(RuntimeError) do
          Neos::Tasks.audit_ownership_guard
        end
        assert_equal 'Duplicate Ruby profile audit re-introduced: audit_profile must stay removed (owned by tools/neos-profile-audit)', err.message
      ensure
        Neos::Tasks.singleton_class.class_eval do
          remove_method :audit_profile
        end
      end
    end
  end
end
