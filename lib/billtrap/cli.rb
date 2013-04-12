# encoding: UTF-8
module BillTrap
  module CLI
    extend Helpers
    extend self
    attr_accessor :args

    def invoke
      require 'cmd/usage'

      case args.first when '-h', '--help', '--usage', '-?', 'help', nil
        puts BillTrap::CLI.usage
        exit 0
      when '-v', '--version'
        puts "BillTrap version #{BillTrap::VERSION}"
        exit 0
      end

      # Grab global options, then stop
      flags = Trollop::options args do
        opt :debug
        stop_on_unknown
      end

      command = args.shift
      # Complete command
      available = commands.select{ |key| key.match(/^#{command}/) }
      if available.size == 1
        require "cmd/#{available[0]}"
        send available[0]
      elsif available.size > 1
        warn "Error: Ambiguous command '#{command}'"
        warn "Matching commands are: #{available.join(", ")}"
      else
        warn "Error: Invalid command #{command.inspect}"
      end
    rescue StandardError, LoadError => e
      raise e if flags && flags[:debug]
      warn e.message
    end

    def commands
      BillTrap::CLI.usage.scan(/\* \w+/).map{|s| s.gsub(/\* /, '')}
    end

    private

    def confirm question
      print "#{question} ? "
      $stdin.gets =~ /\Aye?s?\Z/i
    rescue Interrupt
      # Avoid ugly trace
      warn "\nCaught Interrupt. Exiting"
      exit 1
    end

    def ask_value name, multiline=false
      print "#{name}: "
      if multiline
        puts "(Multiline input, type Ctrl-D or insert END and return to exit)"
        val = ($stdin.gets("END") || '').chomp("END")
        puts
      else
        val = ($stdin.gets || '').chomp
      end
      return val
    rescue Interrupt
      # Avoid ugly trace
      warn "\nCaught Interrupt. Exiting"
      exit 1
    end
  end
end
