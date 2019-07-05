require "snapshot_testing"

module SnapshotTesting
  module RSpec
    def self.included(base)
      base.let :__snapshot_recorder__ do |example|
        SnapshotTesting::Recorder.new(
          name: example.description,
          path: example.metadata[:absolute_file_path],
          update: !ENV['UPDATE_SNAPSHOTS'].nil?
        )
      end

      base.after :each do
        __snapshot_recorder__.commit
      end
    end

    def match_snapshot
      SnapshotTesting::Rspec::MatchSnapshot.new(recorder: __snapshot_recorder__)
    end

    class MatchSnapshot
      attr_reader :expected, :actual

      def initialize(recorder:)
        @recorder = recorder
      end

      def matches?(actual)
        @actual = actual
        @expected = @recorder.record(@actual)
        @actual == @expected
      end

      def failure_message
        expected = ::RSpec::Support::ObjectFormatter.format(@expected)
        actual = ::RSpec::Support::ObjectFormatter.format(@actual)
        "\nexpected: #{expected}\n     got: #{actual}\n\n(compared using ==)\n"
      end

      def diffable?
        true
      end

      def supports_block_expectations?
        false
      end
    end
  end
end
