require "bundler/gem_tasks"
require 'rake'
require 'rdoc/task'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

desc 'Default: run spec.'
task :default => :spec

lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'billtrap/version'
Rake::RDocTask.new do |rdoc|
  version = BillTrap::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "BillTrap #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/billtrap/**/*.rb')
  rdoc.rdoc_files.include('lib/billtrap.rb')
end
