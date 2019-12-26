RSpec.describe SnapshotTesting::Serializer do
  subject(:serializer) {
    described_class.new
  }

  it "accepts everything" do
    expect(serializer.accepts?(1)).to be(true)
    expect(serializer.accepts?(true)).to be(true)
    expect(serializer.accepts?("howdy")).to be(true)
  end

  it "dumps string values" do
    expect(serializer.dump("howdy")).to eq("howdy")
  end

  it "dumps integer values" do
    expect(serializer.dump(1)).to eq("1")
  end

  it "escapes special characters" do
    expect(serializer.dump("\#{foo}\tbar")).to eq("\\\#{foo}\\tbar")
  end

  it "preserves newlines" do
    expect(serializer.dump("hi\nthere")).to eq("hi\nthere")
  end
end
