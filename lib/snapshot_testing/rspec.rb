require "snapshot_testing"

module SnapshotTesting
  module RSpec
    extend ::RSpec::Matchers::DSL

    def self.included(base)
      base.let :__snapshot_recorder__ do |example|
        SnapshotTesting::Recorder.new(
          name: example.description,
          path: example.metadata[:absolute_file_path]
        )
      end

      base.after :each do
        __snapshot_recorder__.commit
      end
    end

    matcher :match_snapshot do |name|
      match do |actual|
        @expected = if name.nil?
          __snapshot_recorder__.record(actual)
        else
          __snapshot_recorder__.record_file(name, actual)
        end

        @expected == actual
      end

      diffable
      description { "match snapshot #{expected_formatted}"}

      failure_message do |actual|
        "\nexpected: #{expected_formatted}\n     got: #{actual_formatted}\n\n(compared using ==)\n"
      end

      def expected_formatted
        ::RSpec::Support::ObjectFormatter.format(@expected)
      end

      def actual_formatted
        ::RSpec::Support::ObjectFormatter.format(@actual)
      end
    end
  end
end
