require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'yard'

YARD::Rake::YardocTask.new do |t|
 t.files   = ['lib/**/*.rb']   # optional
 t.options = ['--any', '--extra', '--opts'] # optional
 t.stats_options = ['--list-undoc']         # optional
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
