require "fileutils"

module SnapshotTesting
  class Recorder
    def initialize(name:, path:, update:)
      @name    = name
      @path    = path
      @update  = update
      @visited = []
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
      key = generate_key
      exists = snapshots.key?(key)
      snapshot = snapshots[key]

      if !exists
        @changes[key] = actual
        actual
      elsif actual == snapshot
        snapshot
      else
        @changes[key] = actual if @update
        @update ? actual : snapshot
      end
    end

    def commit
      unless @changes.empty?
        FileUtils.mkdir_p(snapshot_dir)
        File.write(snapshot_file, Snapshot.dump(snapshots.merge(@changes)))
      end
    end

    private

    def generate_key
      count = @visited.length + 1
      key = "#{@name} #{count}"
      @visited << key
      key
    end
  end
end
