require 'fileutils'

module SnapshotTesting
  class Recorder
    attr_reader :snapshots

    def initialize(path, update: false)
      @path = path
      @changes = {}
      @counter = Hash.new { |h, k| h[k] = 1 }
      @update = update
    end

    def get(name)
      snapshots[key_for(name)]
    end

    def set(name, value)
      @changes[key_for(name)] = value
    end

    def advance(name)
      @counter[name] += 1
    end

    def recording?
      @update
    end

    def commit
      if recording? && !@changes.empty?
        out = Snapshot.dump(snapshots.merge(@changes))
        dir = File.dirname(snapshot_path)
        FileUtils.mkdir_p(dir)
        File.write(snapshot_path, out)
      end
    end

    private

    def key_for(name)
      "#{name} #{@counter[name]}"
    end

    def snapshot_path
      Snapshot.path(@path)
    end

    def snapshots
      Snapshot.load_file(snapshot_path)
    rescue Errno::ENOENT
      {}
    end
  end
end
