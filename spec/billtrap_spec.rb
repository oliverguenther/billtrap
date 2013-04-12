SPEC_RUNNING = true
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'billtrap'))
require 'rspec'
require 'fakefs/safe'

module BillTrap::StubConfig
  def with_stubbed_config options = {}
    defaults = BillTrap::Config.defaults.dup
    BillTrap::Config.stub(:[]).and_return do |k|
      defaults.merge(options)[k]
    end
    yield if block_given?
  end
end


module Helpers
  def invoke command
    BillTrap::CLI.args = command.shellsplit
    BillTrap::CLI.invoke
  end

  def add_client_verified c
    $stdin.should_receive(:gets).and_return(c[:firstname])
    $stdin.should_receive(:gets).and_return(c[:surname])
    $stdin.should_receive(:gets).and_return(c[:company])
    $stdin.should_receive(:gets).and_return(c[:address])
    $stdin.should_receive(:gets).and_return(c[:mail])
    $stdin.should_receive(:gets).and_return(c[:rate])
    $stdin.should_receive(:gets).and_return(c[:currency])
    invoke 'client --add'

    expect($stdout.string).to include "Client #{c[:firstname]} #{c[:surname]} was created with id"
  end

  def add_entry_verified e
    $stdin.should_receive(:gets).and_return(e[:title])
    $stdin.should_receive(:gets).and_return(e[:date])
    $stdin.should_receive(:gets).and_return(e[:unit])
    $stdin.should_receive(:gets).and_return(e[:count])
    $stdin.should_receive(:gets).and_return(e[:price])
    $stdin.should_receive(:gets).and_return(e[:notes])
    invoke 'entry --add'

    expect($stdout.string).to match(/Added entry \(#\d+\) to current invoice/)
  end
end

RSpec.configure do |config|
  config.include Helpers
  config.around(:each) do |example|
    # Make DBs rollback all changes
    Sequel.transaction([BillTrap::DB, BillTrap::TT_DB], :rollback=>:always) do
     example.run
   end
  end
end

describe BillTrap do
  include BillTrap::StubConfig
  before do
    with_stubbed_config
  end


  before :each do
    $stdout = StringIO.new
    $stdin = StringIO.new
    $stderr = StringIO.new
  end

  describe 'CLI' do
    describe 'with no argument given' do
      it "should display usage and exit" do
        expect(lambda { invoke '' }).to raise_error SystemExit
        expect($stdout.string).to include "Usage: bt COMMAND"
        end
      end
    end

    describe 'with an invalid subcommand' do
      it "should output an error" do
        invoke 'foozbar'
        expect($stderr.string).to include 'Error: Invalid command "foozbar"'
      end
    end

    describe 'configure' do
      it "should write a config file" do
        FakeFS do
          billtrap_home = ENV['BILLTRAP_HOME'] || File.join(ENV['HOME'], '.billtrap')
          FileUtils.mkdir_p(billtrap_home)
          config_file = BillTrap::Config::CONFIG_PATH
          FileUtils.rm(config_file) if File.exist? config_file
          expect(File.exist?(config_file)).to be_false
          invoke "configure"
          expect(File.exist?(config_file)).to be_true
        end
      end

      it "should display the path to the config file" do
        FakeFS do
          invoke "configure"
          expect($stdout.string).to eq "Config file written to: \"#{ENV['HOME']}/.billtrap/billtrap.yml\"\n"
        end
      end
    end

    describe 'client' do
      it 'should allow to add and remove clients' do

          add_client_verified(
            :firstname => 'John',
            :surname => 'Doe',
            :company => 'Doemasters Inc.',
            :address => "Somestreet xyz\n 12345Sometown",
            :mail => 'jdoe@example.com',
            :rate => '25',
            :currency => 'EUR'
          )

          expect(BillTrap::Client.all.size).to eq 1
          expect(BillTrap::Client[1].name).to eq 'John Doe'
          expect(BillTrap::Client[1].company).to eq'Doemasters Inc.'

          # Assume client doesn't confirm deletion
          $stdin.should_receive(:gets).and_return('n')
          invoke 'client --delete 1'
          expect(BillTrap::Client.all.size).to eq 1

          $stdin.should_receive(:gets).and_return('y')
          invoke 'client --delete 1'
          expect(BillTrap::Client.all.size).to eq 0
      end
    end

    describe 'entry' do
      it 'should allow to add and delete new invoice entries' do

        invoke 'new'
        add_entry_verified(
          :title => 'Entry1',
          :date => '2013-04-10',
          :count => '2',
          :price => '25'
        )

        expect(BillTrap::InvoiceEntry.all.size).to eq 1
        expect(BillTrap::Invoice.current.total).to eq Money.new('5000', 'USD')

        add_entry_verified(
          :title => 'Entry2',
          :date => '2013-04-11',
          :count => '2',
          :price => '12.51'
        )

        expect(BillTrap::InvoiceEntry[1].title).to eq 'Entry1'
        expect(BillTrap::InvoiceEntry[2].title).to eq 'Entry2'
        expect(BillTrap::InvoiceEntry[1].invoice_id).to eq 1
        expect(BillTrap::InvoiceEntry[2].invoice_id).to eq 1
        expect(BillTrap::Invoice.current.total).to eq Money.new('7502', 'USD')

        $stdin.should_receive(:gets).and_return('n')
        invoke 'entry --delete 1'
        expect(BillTrap::InvoiceEntry.all.size).to eq 2

        $stdin.should_receive(:gets).and_return('y')
        invoke 'entry --delete 1'
        expect(BillTrap::InvoiceEntry[1]).to eq nil
        expect(BillTrap::InvoiceEntry.all.size).to eq 1
        expect(BillTrap::Invoice.current.total).to eq Money.new('2502', 'USD')
      end
    end

    describe 'in' do
      it 'should switch active invoices' do
        invoke 'new --name "Some important project"'
        invoke 'new --name "Support"'

        expect(BillTrap::Invoice.all.size).to eq 2
        expect(BillTrap::Invoice.current.name).to eq 'Support'
        expect(BillTrap::Invoice.current.id).to eq 2

        invoke 'in 1'
        expect(BillTrap::Invoice.current.name).to eq 'Some important project'
        expect(BillTrap::Invoice.current.id).to eq 1
      end
    end

    describe 'new' do
      it 'should allow to set date and client' do
        add_client_verified(
          :firstname => 'John',
          :surname => 'Doe',
          :company => 'Doemasters Inc.',
          :address => "Somestreet xyz\n 12345Sometown",
          :mail => 'jdoe@example.com',
          :rate => '25',
          :currency => 'EUR'
        )

        # Setting by id
        invoke 'new --client 1'
        expect(BillTrap::Invoice.current.client.name).to eq 'John Doe'

      end
    end

    describe 'set' do
        it 'should allow to set client for current invoice' do
          add_client_verified(
            :firstname => 'John',
            :surname => 'Doe',
            :company => 'Doemasters Inc.',
            :address => "Somestreet xyz\n 12345Sometown",
            :mail => 'jdoe@example.com',
            :rate => '25',
            :currency => 'EUR'
          )

          expect(BillTrap::Client.all.size).to eq 1
          expect(BillTrap::Client[1].name).to eq 'John Doe'

          # Create invoice
          $stdout = StringIO.new
          invoke 'new'
          expect($stdout.string).to include "Created invoice #1"
          expect(BillTrap::Invoice.current[:id]).to eq 1
          invoke 'set client 1'

          expect($stdout.string).to include 'SET client to John Doe (#1)'

          # Expect warning output
          invoke 'set client 2'
          expect($stderr.string).to include "Error: Can't find Client with id '2'"
          expect(BillTrap::Invoice.current.client.name).to eq 'John Doe'
      end

      it 'should set the current invoice name' do
        invoke 'new --name "Foobar"'
        expect(BillTrap::Invoice.current.name).to eq 'Foobar'

        invoke 'set name "Important project"'
        expect($stdout.string).to include "SET name to 'Important project'"
        expect(BillTrap::Invoice.current.name).to eq 'Important project'
      end

      it 'should set the current invoice date' do
        invoke 'new'
        expect(BillTrap::Invoice.current.created).to eq Date.today

        invoke 'set date 2013-04-10'
        expect(BillTrap::Invoice.current.created).to eq Date.parse('2013-04-10')

        # with no args sets to today
        invoke 'set date'
        expect(BillTrap::Invoice.current.created).to eq Date.today
      end

      it 'should set the current invoice sent date' do
        invoke 'new'
        expect(BillTrap::Invoice.current.sent).to eq nil

        invoke 'set sent 2013-04-10'
        expect(BillTrap::Invoice.current.sent).to eq Date.parse('2013-04-10')

        invoke 'set sent'
        expect(BillTrap::Invoice.current.sent).to eq nil
      end

      it 'should set arbitrary attributes' do
        invoke 'new'
        expect(BillTrap::Invoice.current.sent).to eq nil

        invoke 'set foo bar'
        expect(BillTrap::Invoice.current.attributes['foo']).to eq 'bar'

        invoke 'set foo notbar'
        expect(BillTrap::Invoice.current.attributes['foo']).to eq 'notbar'
      end
    end
end
