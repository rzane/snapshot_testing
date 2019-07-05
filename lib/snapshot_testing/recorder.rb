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
      pastel   = Pastel.new
      stale    = snapshots.keys.select { |key| stale_key?(key) }
      obsolete = @update ? [] : stale
      removed  = @update ? stale : []

      result = snapshots.merge(@inserts).merge(@updates).reject do |key, _|
        stale.include?(key)
      end

      log(:written, @inserts.length, :green) if @inserts.any?
      log(:updated, @updates.length, :green) if @updates.any?
      log(:removed, stale.length, :green) if removed.any?
      log(:obsolete, stale.length, :yellow) if obsolete.any?

      if @inserts.any? || @updates.any? || removed.any?
        write(result)
      end
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
