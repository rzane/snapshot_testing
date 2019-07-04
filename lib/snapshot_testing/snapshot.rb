require 'pathname'

module SnapshotTesting
  module Snapshot
    DIR = "__snapshots__".freeze
    TEMPLATE = "snapshots[%s] = <<~SNAP\n%s\nSNAP\n".freeze

    def self.path(source)
      dirname = File.dirname(source)
      basename = File.basename(source)
      File.join(dirname, DIR, "#{basename}.snap")
    end

    def self.load_file(file)
      load File.read(file)
    end

    def self.load(input)
      snapshots = {}
      eval(input)
      snapshots.transform_values(&:chomp)
    end

    def self.dump(snapshot)
      entries = snapshot.map do |name, value|
        format(TEMPLATE, name.inspect, value)
      end

      entries.join("\n")
    end
  end
end
