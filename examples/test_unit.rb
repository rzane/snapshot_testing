require "bundler/setup"
require "test/unit"
require "snapshot_testing/test_unit"

class ExampleTest < Test::Unit::TestCase
  include SnapshotTesting::TestUnit

  def test_snapshot
    assert_snapshot "hello"
    assert_snapshot "goodbye"
  end

  def test_named_snapshot
    assert_snapshot "named.unit.txt", "named"
  end

  define_method "test_escapes_regex_[]" do
    assert_snapshot "hello"
  end
end
