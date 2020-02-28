require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

module Color
  def self.bold(msg); "\e[1m#{msg}\e[22m" end
  def self.pink(msg); "\e[35m#{msg}\e[0m" end
  def self.cyan(msg); "\e[36m#{msg}\e[0m" end
end

task :examples do
  suites = [
    ["RSpec", "examples/rspec.rb -f progress --no-color"],
    ["Minitest", "examples/minitest.rb"],
    ["TestUnit", "examples/test_unit.rb --no-use-color"]
  ]

  rm_rf "examples/__snapshots__/"
  suites.each do |name, test_file|
    puts Color.bold("==== #{name} ==============================")
    puts Color.cyan("==>> Running #{name} for the first time...")
    ruby test_file
    puts "\n\n"
    puts Color.pink("==>> Running #{name} against saved snapshots...")
    ruby test_file
    puts "\n\n"
  end
end

task :default => :spec
