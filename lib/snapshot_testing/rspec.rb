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
        @actual = actual
        @expected = if name.nil?
          __snapshot_recorder__.record(actual)
        else
          __snapshot_recorder__.record_file(name, actual)
        end

        @expected == @actual
      end

      description { "match snapshot #{@expected.inspect}"}

      failure_message do
        diff = ::RSpec::Expectations.differ.diff(@actual, @expected)

        message = "\nexpected: #{@expected.inspect}\n     got: #{@actual.inspect}\n"
        message = "#{message}\nDiff: #{diff}" unless diff.strip.empty?
        message
      end
    end
  end
end
