RSpec.describe SnapshotTesting::Snapshot do
  let(:data) {
    { "hello" => "world", "foo" => "bar\nbaz" }
  }

  let(:snapshot) {
    <<~EOS
    snapshots["hello"] = <<~SNAP
    world
    SNAP

    snapshots["foo"] = <<~SNAP
    bar
    baz
    SNAP
    EOS
  }

  it "loads snapshots" do
    expect(SnapshotTesting::Snapshot.load(snapshot)).to eq(data)
  end

  it "dumps snapshots" do
    expect(SnapshotTesting::Snapshot.dump(data)).to eq(snapshot)
  end
end
