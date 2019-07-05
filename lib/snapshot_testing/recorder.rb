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

    def snapshot_dir
      File.join(File.dirname(@path), "__snapshots__")
    end

    def snapshot_file
      File.join(snapshot_dir, "#{File.basename(@path)}.snap")
    end

    def snapshots
      Snapshot.load_file(snapshot_file)
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
        FileUtils.mkdir_p(snapshot_dir)
        File.write(snapshot_file, Snapshot.dump(snapshots.merge(@changes)))
      end
    end
  end
end
