require 'rake'

require 'rspec'
require 'rspec/core/rake_task'


desc "Run all the test suites for this project"
task :build => [:"build:spec"]

namespace :build do

  RSpec::Core::RakeTask.new(:spec)

end

task :default => [:build]
