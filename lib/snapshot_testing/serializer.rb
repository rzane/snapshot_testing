module SnapshotTesting
  class Serializer
    def accepts?(value)
      true
    end

    def dump(value)
      value.to_s
    end
  end
end
