require "fileutils"

module SnapshotTesting
  class Recorder
    def initialize(name:, path:, update:)
      @name    = name
      @path    = path
      @update  = update
      @count   = 1
      @changes = {}
    end

    def snapshot_path
      Snapshot.path(@path)
    end

    def snapshots
      Snapshot.load_file(snapshot_path)
    rescue Errno::ENOENT
      {}
    end

    def record(actual)
      key = "#{@name} #{@count}"
      exists = snapshots.key?(key)
      snapshot = snapshots[key]

      if !exists
        @changes[key] = actual
        @count += 1
        actual
      elsif actual == snapshot
        @count += 1
        snapshot
      else
        @changes[key] = actual if @update
        @count += 1
        @update ? actual : snapshot
      end
    end

    def commit
      unless @changes.empty?
        out = Snapshot.dump(snapshots.merge(@changes))
        dir = File.dirname(snapshot_path)
        FileUtils.mkdir_p(dir)
        File.write(snapshot_path, out)
      end
    end
  end
end
