module SnapshotTesting
  class Serializer
    def accepts?(value)
      true
    end

    def dump(value)
      value.to_s.dump.gsub("\\n", "\n")[1..-2]
    end
  end
end
