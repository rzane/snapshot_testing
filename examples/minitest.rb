require "bundler/setup"
require "minitest/autorun"
require "snapshot_testing/minitest"

class ExampleTest < Minitest::Test
  include SnapshotTesting::Minitest

  def test_snapshot
    assert_snapshot "hello"
    assert_snapshot "goodbye"
  end

  def test_named_snapshot
    assert_snapshot "named.minitest.test.txt", "named"
  end

  define_method "test_escapes_regex_[]" do
    assert_snapshot "hello"
  end
end

class ExampleSpec < Minitest::Spec
  include SnapshotTesting::Minitest

  it "takes a snapshot" do
    _("hello").must_match_snapshot
    _("goodbye").must_match_snapshot
  end

  it "takes a named snapshot" do
    _("named").must_match_snapshot "named.minitest.spec.txt"
  end

  it "escapes regex []" do
    _("hello").must_match_snapshot
  end
end
