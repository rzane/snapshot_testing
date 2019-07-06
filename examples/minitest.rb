require "bundler/setup"
require "minitest/autorun"
require "snapshot_testing/minitest"

class ExampleTest < Minitest::Test
  include SnapshotTesting::Minitest

  def test_snapshot
    assert_snapshot "hello"
    assert_snapshot "goodbye"
  end
end

class ExampleSpec < Minitest::Spec
  include SnapshotTesting::Minitest

  it "takes a snapshot" do
    "hello".must_match_snapshot
    "goodbye".must_match_snapshot
  end
end
