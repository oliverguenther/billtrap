# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'billtrap/version'

Gem::Specification.new do |spec|
  spec.name           = "billtrap"
  spec.version        = BillTrap::VERSION
  spec.authors        = ["Oliver Günther"]
  spec.email          = ["mail@oliverguenther.de"]
  spec.summary        = "Command line invoice management."
  spec.description    = "This gem provides invoice management with imported time slices from the Timetrap gem."
  spec.homepage       = "http://github.com/oliverguenther/billtrap/"
  spec.license        = "MIT"

  spec.files          = `git ls-files`.split($/)
  spec.bindir         = "bin"
  spec.executables    = ['bt']
  spec.test_files     = ['spec/']
  spec.require_paths  = ['lib']

  spec.add_dependency "sequel", ">= 3.9.0"
  spec.add_dependency "sqlite3", ">= 1.3.3"
  spec.add_dependency "chronic", ">= 0.6.4"
  spec.add_dependency "json", ">= 1.4.6"
  spec.add_dependency "trollop", ">= 2.0"
  spec.add_dependency "money", ">= 5.0"
  spec.add_dependency "timetrap", ">= 1.5"
  spec.add_dependency "rubyzip"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', '~> 2'
  spec.add_development_dependency 'fakefs'
end
