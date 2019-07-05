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
