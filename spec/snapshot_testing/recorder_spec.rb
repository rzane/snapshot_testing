RSpec.describe SnapshotTesting::Recorder do
  subject(:recorder) { |example|
    SnapshotTesting::Recorder.new(
      name: "example",
      path: "/foo/bar_spec.rb",
      update: example.metadata.fetch(:update, false)
    )
  }

  describe "#snapshot_path" do
    it "translates the path" do
      expect(recorder.snapshot_path).to eq("/foo/__snapshots__/bar_spec.rb.snap")
    end
  end

  describe "#snapshots" do
    it "loads snapshots from a file" do
      allow(File).to receive(:read).and_return(<<~EOS)
        snapshots["example"] = <<~SNAP
        hello
        SNAP
      EOS

      expect(recorder.snapshots).to eq("example" => "hello")
    end

    it "defaults to an empty hash when file does not exist" do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
      expect(recorder.snapshots).to eq({})
    end
  end

  describe "#record" do
    context "when the snapshot matches" do
      before do
        record_snapshots("example 1" => "hello")
      end

      it "returns the actual value" do
        expect(recorder.record("hello")).to eq("hello")
      end

      it "records the actual value" do
        recorder.record("hello")
        expect(recorder.snapshots).to eq("example 1" => "hello")
      end
    end

    context "when the snapshot does not exist" do
      before do
        record_snapshots({})
      end

      it "returns the actual value" do
        expect(recorder.record("hello")).to eq("hello")
      end

      it "records the actual value" do
        recorder.record("hello")
        expect(recorder.snapshots).to eq("example 1" => "hello")
      end
    end

    context "when the snapshot does not match" do
      before do
        record_snapshots("example 1" => "goodbye")
      end

      it "returns the snapshot value" do
        expect(recorder.record("hello")).to eq("goodbye")
      end

      it "returns the actual value when updating", :update do
        expect(recorder.record("hello")).to eq("hello")
      end

      it "does not record the actual value" do
        recorder.record("hello")
        expect(recorder.snapshots).to eq("example 1" => "goodbye")
      end
    end
  end

  describe "#commit" do
    before do
      allow(recorder).to receive(:warn)
      allow(recorder).to receive(:write_snapshots)
    end

    context "when new snapshots are added" do
      before do
        record_snapshots("example 1" => "hello")
        recorder.record("hello")
        recorder.record("goodbye")
        recorder.commit
      end

      it "writes snapshots" do
        expect(recorder).to have_received(:write_snapshots)
        expect(snapshots).to eq("example 1" => "hello", "example 2" => "goodbye")
      end

      it "warns about written snapshots" do
        expect(recorder).to have_received(:warn).with(/1 snapshot written/)
      end
    end

    context "when snapshots are updated", :update do
      before do
        record_snapshots("example 1" => "hello", "example 2" => "change me")
        recorder.record("hello")
        recorder.record("goodbye")
        recorder.commit
      end

      it "writes snapshots" do
        expect(recorder).to have_received(:write_snapshots)
        expect(snapshots).to eq("example 1" => "hello", "example 2" => "goodbye")
      end

      it "warns about updated snapshots" do
        expect(recorder).to have_received(:warn).with(/1 snapshot updated/)
      end
    end

    context "when keys are stale" do
      before do
        record_snapshots("example 1" => "hello", "example 2" => "stale")
        recorder.record("hello")
        recorder.commit
      end

      it "does not write snapshots" do
        expect(recorder).not_to have_received(:write_snapshots)
      end

      it "warns about obsolete snapshots" do
        expect(recorder).to have_received(:warn).with(/1 snapshot obsolete/)
      end

      context "when updating", :update do
        it "writes snapshots" do
          expect(recorder).to have_received(:write_snapshots)
          expect(snapshots).to eq("example 1" => "hello")
        end

        it "warns about removed snapshots" do
          expect(recorder).to have_received(:warn).with(/1 snapshot removed/)
        end
      end
    end
  end

  def snapshots
    recorder.instance_variable_get(:@snapshots)
  end

  def record_snapshots(snapshots)
    recorder.instance_variable_set(:@snapshots, snapshots)
  end
end
