require "snapshot_testing"

module SnapshotTesting
  module Minitest
    def self.included(_)
      return unless defined?(::Minitest::Expectations)
      return if ::Minitest::Expectations.method_defined?(:must_match_snapshot)
      ::Minitest::Expectations.infect_an_assertion(:assert_snapshot, :must_match_snapshot, true)
    end

    def before_setup
      @__snapshot_recorder__ = SnapshotTesting::Recorder.new(
        name: name,
        path: method(name).source_location.first
      )
      super
    end

    def after_teardown
      super
      @__snapshot_recorder__.commit
    end

    def assert_snapshot(name = nil, actual)
      if name.nil?
        assert_equal(@__snapshot_recorder__.record(actual), actual)
      else
        assert_equal(@__snapshot_recorder__.record_file(name, actual), actual)
      end
    end
  end
end
