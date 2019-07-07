RSpec.describe SnapshotTesting::Snapshot do
  class Jawn
    attr_reader :value
    def initialize(value)
      @value = value
    end
  end

  class JawnSerializer
    def accepts?(object)
      object.is_a? Jawn
    end

    def dump(jawn)
      jawn.value
    end
  end

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
    SnapshotTesting::Snapshot.use(JawnSerializer.new)

    snapshot = SnapshotTesting::Snapshot.dump("jawn" => Jawn.new("jint"))

    expect(snapshot).to eq(<<~EOS)
    snapshots["jawn"] = <<-SNAP
    jint
    SNAP
    EOS
  end
end
