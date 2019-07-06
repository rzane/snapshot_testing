require "fileutils"
require "pastel"

module SnapshotTesting
  class Recorder
    def initialize(name:, path:, update:)
      @name    = name
      @path    = path
      @update  = update
      @visited = []
      @inserts = {}
      @updates = {}
    end

    def snapshot_dir
      File.join(File.dirname(@path), "__snapshots__")
    end

    def snapshot_file
      File.join(snapshot_dir, "#{File.basename(@path)}.snap")
    end

    def snapshots
      @snapshots ||= Snapshot.load_file(snapshot_file)
    rescue Errno::ENOENT
      @snapshots ||= {}
    end

    def record(actual)
      count    = @visited.length + 1
      key      = "#{@name} #{count}"
      exists   = snapshots.key?(key)
      snapshot = snapshots[key]

      @visited << key

      if !exists
        @inserts[key] = actual
        actual
      elsif actual == snapshot
        snapshot
      else
        @updates[key] = actual if @update
        @update ? actual : snapshot
      end
    end

    def commit
      stale  = snapshots.keys.select { |key| stale_key?(key) }

      result = snapshots.merge(@inserts).merge(@updates)
      result = result.reject { |key, _| stale.include?(key) } if @update

      write(result) if result != snapshots

      log(:written, @inserts.length, :green) if @inserts.any?
      log(:updated, @updates.length, :green) if @updates.any?
      log(:removed, stale.length, :green) if @update && stale.any?
      log(:obsolete, stale.length, :yellow) if !@update && stale.any?
    end

    private

    def log(status, count, color)
      label = count == 1 ? "snapshot" : "snapshots"
      message = "#{count} #{label} #{status}."
      warn Pastel.new.public_send(color, message)
    end

    def write(snapshots)
      FileUtils.mkdir_p(snapshot_dir)
      File.write(snapshot_file, Snapshot.dump(snapshots))
    end

    def stale_key?(key)
      name = key.sub(/\s\d+$/, "")
      name == @name && !@visited.include?(key)
    end
  end
end
