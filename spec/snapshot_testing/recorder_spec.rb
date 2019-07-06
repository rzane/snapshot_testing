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

      it "returns the actual value" do
        expect(recorder.record("hello")).to eq("hello")
      end

      it "records the actual value" do
        recorder.record("hello")
        expect(state).to eq("example 1" => "hello")
      end
    end

    context "when the snapshot does not exist" do
      before do
        allow(recorder).to receive(:snapshots).and_return({})
      end

      it "returns the actual value" do
        expect(recorder.record("hello")).to eq("hello")
      end

      it "records the actual value" do
        recorder.record("hello")
        expect(state).to eq("example 1" => "hello")
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

      it "records the actual value" do
        recorder.record("hello")
        expect(state).to eq("example 1" => "hello")
      end
    end
  end

  describe "#commit" do
    before do
      allow(recorder).to receive(:warn)
      allow(recorder).to receive(:write)
    end

    context "when new snapshots are added" do
      before do
        allow(recorder).to receive(:snapshots).and_return("example 1" => "hello")
        recorder.record("hello")
        recorder.record("goodbye")
        recorder.commit
      end

      it "writes snapshots" do
        expect(recorder).to have_received(:write).with(
          "example 1" => "hello",
          "example 2" => "goodbye"
        )
      end

      it "warns about written snapshots" do
        expect(recorder).to have_received(:warn).with(/1 snapshot written/)
      end
    end

    context "when snapshots are updated", :update do
      before do
        allow(recorder).to receive(:snapshots).and_return(
          "example 1" => "hello",
          "example 2" => "change me"
        )

        recorder.record("hello")
        recorder.record("goodbye")
        recorder.commit
      end

      it "writes snapshots" do
        expect(recorder).to have_received(:write).with(
          "example 1" => "hello",
          "example 2" => "goodbye"
        )
      end

      it "warns about updated snapshots" do
        expect(recorder).to have_received(:warn).with(/1 snapshot updated/)
      end
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

      it "does not write snapshots" do
        expect(recorder).not_to have_received(:write)
      end

      it "warns about obsolete snapshots" do
        expect(recorder).to have_received(:warn).with(/1 snapshot obsolete/)
      end

      context "when updating", :update do
        it "writes snapshots" do
          expect(recorder).to have_received(:write).with("example 1" => "hello")
        end

        it "warns about removed snapshots" do
          expect(recorder).to have_received(:warn).with(/1 snapshot removed/)
        end
      end
    end
  end

  def state
    recorder.instance_variable_get(:@state)
  end
end
