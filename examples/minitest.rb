require "minitest/autorun"
require "bundler/setup"
require "snapshot_testing/minitest"

class ExampleTest < Minitest::Test
  prepend SnapshotTesting::Minitest

  def test_snapshot
    assert_snapshot "hello"
    assert_snapshot "goodbye"
  end
end

class ExampleSpec < Minitest::Spec
  prepend SnapshotTesting::Minitest

  it "takes a snapshot" do
    "hello".must_match_snapshot
    "goodbye".must_match_snapshot
  end
end
