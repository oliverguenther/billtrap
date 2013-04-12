# encoding: utf-8
require "rubygems"
require 'sequel'
# Load migrations
Sequel.extension :migration, :core_extensions
# Load inflector (String.classify)
Sequel.extension :inflector

require 'chronic'
require 'money'
require 'yaml'
require 'erb'
require 'trollop'
require 'pathname'

# require serenity 0.2.2
require File.join(File.dirname(__FILE__), 'serenity', 'serenity')

# Set billtrap home
BILLTRAP_HOME = ENV['BILLTRAP_HOME'] || File.join(ENV['HOME'], '.billtrap')


BILLTRAP_PATH = Pathname.new(__FILE__).realpath.dirname.to_s
$:.unshift(BILLTRAP_PATH + '/billtrap')
require 'version'
require 'config'
require 'helpers'
require 'cli'
require 'adapters'
module BillTrap
  # Force encoding to utf-8
  Encoding.default_internal= Encoding::UTF_8
  Sequel::Model.plugin :force_encoding, Encoding::UTF_8


  unless File.directory? BILLTRAP_HOME
    FileUtils.mkdir BILLTRAP_HOME
  end


  # We need to inclue spec testing here, as RSpec doesn't allow
  # stubs in around blocks, but we need around blocks for Sequel transactions
	DB_NAME = defined?(SPEC_RUNNING) ? "sqlite://test.db" : BillTrap::Config['database']
	DB = Sequel.connect(DB_NAME)

  # Update to latest migration, if necessary
  unless (Sequel::Migrator.is_current? DB, File.dirname(__FILE__) + '/../migrations/')
    Sequel::Migrator.run(DB, File.dirname(__FILE__) + '/../migrations/')
  end

  # Open TT timetrap_databasee
  TT_DB_NAME = defined?(SPEC_RUNNING) ? "sqlite://testTT.db" : BillTrap::Config['timetrap_database']
  TT_DB = Sequel.connect(TT_DB_NAME)

end
require 'models'
