require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

def info(message)
  puts "\033[1m#{message}\033[0m"
end

task :examples do
  info "==>> Running RSpec..."
  ruby "examples/rspec.rb -f progress"

  info "\n\n==>> Running Minitest..."
  ruby "examples/minitest.rb"

  info "\n\n==>> Running TestUnit..."
  ruby "examples/test_unit.rb"
end

task :default => :spec
