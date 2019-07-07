require "pathname"
require "snapshot_testing/serializer"

module SnapshotTesting
  module Snapshot
    TEMPLATE = "snapshots[%s] = <<-SNAP\n%s\nSNAP\n".freeze

    @@serializers = [SnapshotTesting::Serializer.new]

    def self.use(serializer)
      @@serializers.unshift(serializer)
    end

    def self.load_file(file)
      load File.read(file)
    end

    def self.load(input)
      snapshots = {}
      eval(input)
      snapshots.transform_values(&:chomp)
    end

    def self.dump(values)
      entries = values.map do |name, value|
        serializer = @@serializers.find { |s| s.accepts?(value) }
        snapshot = serializer.dump(value)
        format(TEMPLATE, name.inspect, snapshot)
      end

      entries.join("\n")
    end
  end
end
