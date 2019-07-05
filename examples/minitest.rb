require "minitest/autorun"
require "bundler/setup"
require "snapshot_testing/minitest"

class Minitest::Test
  include SnapshotTesting::Minitest
end

class Minitest::Spec
  include SnapshotTesting::Minitest
end

class ExampleTest < Minitest::Test
  def test_snapshot
    assert_snapshot "hello"
    assert_snapshot "goodbye"
  end
end

class ExampleSpec < Minitest::Spec
  it "takes a snapshot" do
    "hello".must_match_snapshot
    "goodbye".must_match_snapshot
  end
end
