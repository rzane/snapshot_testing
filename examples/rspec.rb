require "bundler/setup"
require "snapshot_testing/rspec"

RSpec.configure do |config|
  config.include SnapshotTesting::RSpec
end

RSpec.describe "Example" do
  it "takes a snapshot" do
    expect("hello").to match_snapshot
    expect("goodbye").to match_snapshot
  end
end
