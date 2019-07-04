require 'fileutils'

module SnapshotTesting
  class Recorder
    attr_reader :snapshots

    def initialize(path, update: false)
      @path = path
      @update = update
      @changes = {}
      @counter = Hash.new { |h, k| h[k] = 1 }
    end

    def record(name, actual)
      key = "#{name} #{@counter[name]}"
      snapshot = snapshots[key]

      if snapshot.nil?
        @changes[key] = actual
        @counter[name] += 1
        [actual, actual]
      elsif actual == snapshot
        @counter[name] += 1
        [actual, snapshot]
      else
        @changes[key] = actual if @update
        @counter[name] += 1
        [actual, @update ? actual : snapshot]
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

    private

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
