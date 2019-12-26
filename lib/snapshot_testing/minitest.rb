require "snapshot_testing"

module SnapshotTesting
  module Minitest
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

    if respond_to? :infect_an_assertion
      infect_an_assertion :assert_snapshot, :must_match_snapshot
    end
  end
end
