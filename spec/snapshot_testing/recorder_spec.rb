RSpec.describe SnapshotTesting::Recorder do
  let(:update) { false }

  subject(:recorder) {
    SnapshotTesting::Recorder.new(
      name: "example",
      path: "/foo/bar_spec.rb",
      update: update
    )
  }

  describe "snapshot_path" do
    it "translates the path" do
      expect(recorder.snapshot_path).to eq("/foo/__snapshots__/bar_spec.rb.snap")
    end
  end
end
