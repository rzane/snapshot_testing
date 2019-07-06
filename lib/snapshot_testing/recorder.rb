require "fileutils"
require "pastel"

module SnapshotTesting
  class Recorder
    def initialize(name:, path:, update:)
      @name   = name
      @path   = path
      @update = update
      @state  = {}
    end

    def snapshot_dir
      File.join(File.dirname(@path), "__snapshots__")
    end

    def snapshot_file
      File.join(snapshot_dir, "#{File.basename(@path)}.snap")
    end

    def snapshots
      @snapshots ||= begin
        Snapshot.load_file(snapshot_file)
      rescue Errno::ENOENT
        {}
      end
    end

    def record(actual)
      key = "#{@name} #{@state.length + 1}"

      # keep track each encounter, so we can diff later
      @state[key] = actual

      # pass the test when updating snapshots
      return actual if @update

      # pass the test when the snapshot does not exist
      return actual unless snapshots.key?(key)

      # otherwise, compare actual to the snapshot
      snapshots[key]
    end

    def commit
      added   = @state.select { |k, _| !snapshots.key?(k) }
      changed = @state.select { |k, v| snapshots.key?(k) && snapshots[k] != v }
      removed = snapshots.keys.select do |k|
        k.match?(/^#{@name}\s\d+$/) && !@state.key?(k)
      end

      result = snapshots.merge(added)
      result = result.merge(changed) if @update
      result = result.reject { |k, _| removed.include?(k) } if @update

      write(result) if result != snapshots
      log(added.length, :written, :green) if added.any?
      log(changed.length, :updated, :green) if @update && changed.any?
      log(removed.length, :removed, :green) if @update && removed.any?
      log(removed.length, :obsolete, :yellow) if !@update && removed.any?
    end

    private

    def log(count, status, color)
      label = count == 1 ? "snapshot" : "snapshots"
      message = "#{count} #{label} #{status}."
      warn Pastel.new.public_send(color, message)
    end

    def write(snapshots)
      FileUtils.mkdir_p(snapshot_dir)
      File.write(snapshot_file, Snapshot.dump(snapshots))
    end
  end
end
