require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :examples do
  ruby 'examples/minitest.rb'
  ruby 'examples/test_unit.rb'
  sh 'rspec', 'examples/rspec.rb'
end

task :default => :spec
