require "snapshot_testing/version"
require "snapshot_testing/snapshot"
require "snapshot_testing/recorder"

module SnapshotTesting
  def self.update?
    !ENV["UPDATE_SNAPSHOTS"].nil?
  end
end
