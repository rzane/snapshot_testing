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

      it "returns the snapshot value" do
        expect(recorder.record("hello")).to eq("hello")
      end

      it "returns the snapshot value when updating", :update do
        expect(recorder.record("hello")).to eq("hello")
      end

      it "does not record a change" do
        recorder.record("hello")
        expect(changes).to eq({})
      end

      it "does not record a change when updating", :update do
        recorder.record("hello")
        expect(changes).to eq({})
      end

      it "records the visit" do
        recorder.record("hello")
        expect(visited).to eq(["example 1"])
      end
    end

    context "when the snapshot does not exist" do
      before do
        allow(recorder).to receive(:snapshots).and_return({})
      end

      it "returns the actual value" do
        expect(recorder.record("hello")).to eq("hello")
      end

      it "returns the actual value when updating", :update do
        expect(recorder.record("hello")).to eq("hello")
      end

      it "records a change" do
        recorder.record("hello")
        expect(changes).to eq("example 1" => "hello")
      end

      it "records a change when updating", :update do
        recorder.record("hello")
        expect(changes).to eq("example 1" => "hello")
      end

      it "records the visit" do
        recorder.record("hello")
        expect(visited).to eq(["example 1"])
      end
    end

    context "when the snapshot does not match" do
      before do
        allow(recorder).to receive(:snapshots).and_return("example 1" => "goodbye")
      end

      it "returns the snapshot value" do
        expect(recorder.record("hello")).to eq("goodbye")
      end

      it "returns the actual value when updating", :update do
        expect(recorder.record("hello")).to eq("hello")
      end

      it "does not record a change" do
        recorder.record("hello")
        expect(changes).to eq({})
      end

      it "records a change when updating", :update do
        recorder.record("hello")
        expect(changes).to eq("example 1" => "hello")
      end

      it "records the visit" do
        recorder.record("hello")
        expect(visited).to eq(["example 1"])
      end
    end
  end

  def visited
    recorder.instance_variable_get(:@visited)
  end

  def changes
    recorder.instance_variable_get(:@changes)
  end
end
