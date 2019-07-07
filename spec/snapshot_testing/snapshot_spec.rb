RSpec.describe SnapshotTesting::Snapshot do
  let(:data) {
    {
      "simple" => "foo",
      "multiline" => "foo\nbar",
      "indented" => "  foo"
    }
  }

  let(:snapshot) {
    <<~EOS
    snapshots["simple"] = <<-SNAP
    foo
    SNAP

    snapshots["multiline"] = <<-SNAP
    foo
    bar
    SNAP

    snapshots["indented"] = <<-SNAP
      foo
    SNAP
    EOS
  }

  it "loads snapshots" do
    expect(SnapshotTesting::Snapshot.load(snapshot)).to eq(data)
  end

  it "dumps snapshots" do
    expect(SnapshotTesting::Snapshot.dump(data)).to eq(snapshot)
  end

  it "allows the use of custom serializers" do
    Jawn = Struct.new(:value)
    JawnSerializer = Class.new do
      def accepts?(object) object.is_a? Jawn end
      def dump(jawn) jawn.value end
    end

    data = { "jawn" => Jawn.new("jint") }
    snapshot = <<~EOS
    snapshots["jawn"] = <<-SNAP
    jint
    SNAP
    EOS

    SnapshotTesting::Snapshot.use(JawnSerializer.new)
    expect(SnapshotTesting::Snapshot.dump(data)).to eq(snapshot)
  end
end
