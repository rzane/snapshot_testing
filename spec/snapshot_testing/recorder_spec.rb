RSpec.describe SnapshotTesting::Recorder do
  let(:snapshot_file) {
    <<~EOS
    snapshots["example"] = <<~SNAP
    hello
    SNAP
    EOS
  }

  let(:snapshots) {
    {"example" => "hello"}
  }

  subject(:recorder) { |example|
    SnapshotTesting::Recorder.new(
      name: "example",
      path: "/foo/bar_spec.rb",
      update: example.metadata.fetch(:update, false)
    )
  }

  describe "#snapshot_dir" do
    it "translates the path" do
      expect(recorder.snapshot_dir).to eq("/foo/__snapshots__")
    end
  end

  describe "#snapshot_file" do
    it "translates the path" do
      expect(recorder.snapshot_file).to eq("/foo/__snapshots__/bar_spec.rb.snap")
    end
  end

  describe "#snapshots" do
    it "loads snapshots from a file" do
      allow(File).to receive(:read).and_return(snapshot_file)
      expect(recorder.snapshots).to eq(snapshots)
    end

    it "defaults to an empty hash when file does not exist" do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
      expect(recorder.snapshots).to eq({})
    end
  end

  describe "#record" do
    context "when the snapshot matches" do
      before do
        allow(recorder).to receive(:snapshots).and_return("example 1" => "hello")
      end

      it "does nothing" do
        expect(recorder.record("hello")).to eq("hello")
        expect(inserts).to eq({})
        expect(updates).to eq({})
      end
    end

    context "when the snapshot does not exist" do
      before do
        allow(recorder).to receive(:snapshots).and_return({})
      end

      it "inserts a new snapshot" do
        expect(recorder.record("hello")).to eq("hello")
        expect(visited).to eq(["example 1"])
        expect(inserts).to eq("example 1" => "hello")
        expect(updates).to eq({})
      end
    end

    context "when the snapshot does not match" do
      before do
        allow(recorder).to receive(:snapshots).and_return("example 1" => "goodbye")
      end

      it "does nothing when updates are disabled" do
        expect(recorder.record("hello")).to eq("goodbye")
        expect(visited).to eq(["example 1"])
        expect(inserts).to eq({})
        expect(updates).to eq({})
      end

      it "records an update when updating", :update do
        expect(recorder.record("hello")).to eq("hello")
        expect(visited).to eq(["example 1"])
        expect(inserts).to eq({})
        expect(updates).to eq("example 1" => "hello")
      end
    end
  end

  describe "#commit" do
    before do
      allow(recorder).to receive(:warn)
      allow(recorder).to receive(:write)
    end

    context "when keys are stale" do
      before do
        allow(recorder).to receive(:snapshots).and_return(
          "example 1" => "hello",
          "example 2" => "stale"
        )

        recorder.record("hello")
        recorder.commit
      end

      it "warns about obsolete keys" do
        expect(recorder).to have_received(:warn).with(/1 snapshot obsolete/)
      end

      it "warns about removed keys", :update do
        expect(recorder).to have_received(:warn).with(/1 snapshot removed/)
      end
    end
  end

  def visited
    recorder.instance_variable_get(:@visited)
  end

  def inserts
    recorder.instance_variable_get(:@inserts)
  end

  def updates
    recorder.instance_variable_get(:@updates)
  end
end
