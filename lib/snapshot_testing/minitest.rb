require "snapshot_testing"
require "minitest/spec"

module Minitest::Expectations
  infect_an_assertion :assert_snapshot, :must_match_snapshot, true
end

module SnapshotTesting
  module Minitest
    def before_setup
      @__snapshot_recorder__ = SnapshotTesting::Recorder.new(
        name: name,
        path: method(name).source_location.first,
        update: !ENV['UPDATE_SNAPSHOTS'].nil?
      )
      super
    end

    def after_teardown
      super
      @__snapshot_recorder__.commit
    end

    def assert_snapshot(actual)
      assert_equal(@__snapshot_recorder__.record(actual), actual)
    end
  end
end
