require "bundler/setup"
require "rspec/autorun"
require "snapshot_testing/rspec"

RSpec.configure do |config|
  config.include SnapshotTesting::RSpec
  config.color = false
end

RSpec.describe "Example" do
  it "takes a snapshot" do
    expect("hello").to match_snapshot
    expect("goodbye").to match_snapshot
  end

  it "takes a named snapshot" do
    message = <<~EOS
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam diam
      urna, dignissim a faucibus eu, malesuada vitae tellus. Aliquam dignissim
      volutpat fermentum. Nam ultricies risus ac ornare venenatis.
    EOS

    expect(message).to match_snapshot("named.rspec.txt")
  end

  it "escapes regex []" do
    expect("hello").to match_snapshot
  end
end
