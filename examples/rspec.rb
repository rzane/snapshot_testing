require "bundler/setup"
require "rspec/autorun"
require "snapshot_testing/rspec"

RSpec.configure do |config|
  config.include SnapshotTesting::RSpec
end

RSpec.describe "Example" do
  it "takes a snapshot" do
    expect("hello").to match_snapshot
    expect("goodbye").to match_snapshot
  end

  it "takes a named snapshot" do
    expect("named").to match_snapshot("named.rspec.txt")
  end
end
