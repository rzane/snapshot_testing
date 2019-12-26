require "fileutils"

module SnapshotTesting
  class Recorder
    def initialize(name:, path:, update: SnapshotTesting.update?)
      @name   = name
      @path   = path
      @update = update
      @visited = []
      @added = 0
      @updated = 0
    end

    def snapshot_path
      File.join(snapshots_path, "#{File.basename(path)}.snap")
    end

    def snapshots
      @snapshots ||= begin
        Snapshot.load_file(snapshot_path)
      rescue Errno::ENOENT
        {}
      end
    end

    def record(actual)
      key = "#{name} #{visited.length + 1}"

      self.visited << key

      unless snapshots.key?(key)
        self.added += 1
        self.snapshots[key] = actual
      end

      if update? && actual != snapshots[key]
        self.updated += 1
        self.snapshots[key] = actual
      end

      snapshots[key]
    end

    def commit
      removed = snapshots.keys - visited
      removed = removed.grep(/^#{name}\s\d+$/)
      removed.each { |key| snapshots.delete(key) }

      write_snapshots(snapshots) if write?
      log(added, :written) unless added.zero?
      log(updated, :updated) unless updated.zero?
      log(removed.length, :removed) if update? && !removed.empty?
      log(removed.length, :obsolete) if !update? && !removed.empty?
    end

    protected

    # the number of added snapshots
    attr_accessor :added

    # the number of updated snapshots
    attr_accessor :updated

    # all snapshots that have been compared
    attr_reader :visited

    private

    # the name of the current test
    attr_reader :name

    # the file location of the current test
    attr_reader :path

    # should we update failing snapshots?
    def update?
      @update
    end

    # should we write to the filesystem?
    def write?
      update? || !added.zero?
    end

    def snapshots_path
      File.join(File.dirname(path), "__snapshots__")
    end

    def log(count, status)
      label = count == 1 ? "snapshot" : "snapshots"
      warn "\e[33m#{count} #{label} #{status}\e[0m"
    end

      case color
      when :yellow
        warn "\e[33m#{message}\e[0m"
      when :green
        warn "\e[32m#{message}\e[0m"
      end
    end

    def write_snapshots(snapshots)
      FileUtils.mkdir_p(snapshots_path)
      File.write(snapshot_path, Snapshot.dump(snapshots))
    end
  end
end
