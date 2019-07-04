require "snapshot_testing"

module SnapshotTesting
  module RSpec
    def self.included(base)
      base.after :each do
        __snapshot_recorder__.commit
      end
    end

    def __snapshot_recorder__
      @_snapshot_recorder_ ||= Recorder.new(
        ::RSpec.current_example.metadata[:absolute_file_path],
        update: !ENV['UPDATE_SNAPSHOTS'].nil?
      )
    end

    def match_snapshot
      MatchSnapshot.new(
        recorder: __snapshot_recorder__,
        name: ::RSpec.current_example.description
      )
    end

    class MatchSnapshot
      attr_reader :expected, :actual

      def initialize(name:, recorder:)
        @name = name
        @recorder = recorder
      end

      def matches?(actual)
        @actual, @expected = @recorder.record(@name, actual)
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
