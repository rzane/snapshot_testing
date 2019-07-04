module SnapshotTesting
  module RSpec
    def self.included(base)
      base.after :each do
        snapshot_recorder.commit
      end
    end

    def snapshot_recorder
      @snapshot_recorder ||= Recorder.new(
        ::RSpec.current_example.metadata[:absolute_file_path],
        update: !ENV['UPDATE_SNAPSHOTS'].nil?
      )
    end

    def match_snapshot
      MatchSnapshot.new(
        recorder: __snapshot_recorder,
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
        @actual = actual
        @expected = @recorder.get(@name)

        if @expected.nil?
          @expected = actual
          @recorder.set(@name, actual)
          @recorder.advance(@name)
          true
        elsif @actual == @expected
          @recorder.advance(@name)
          true
        else
          @recorder.set(@name, actual)
          @recorder.advance(@name)
          @recorder.recording?
        end
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
