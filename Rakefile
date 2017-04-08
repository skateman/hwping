require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rake/extensiontask'

Rake::ExtensionTask.new do |ext|
  ext.name = 'webcam'
  ext.ext_dir = 'ext/hwping'
  ext.lib_dir = 'lib/hwping'
end

RSpec::Core::RakeTask.new

task :build => [:clean, :compile]
task :default => :spec
task :test => :spec
