module BillTrap
  module CLI
    def configure
      BillTrap::Config.configure!
      puts "Config file written to: #{BillTrap::Config::CONFIG_PATH.inspect}"
    end
  end
end