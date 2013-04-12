module BillTrap
  module CLI
    def new
      opts = Trollop::options args do
        opt :client, "Optional Client ID", :type => :string, :short => '-c'
        opt :date, "Optional invoice date", :type => :string, :short => '-d'
        opt :name, "Optional invoice name", :type => :string, :short => '-n'
      end

      date =
        if opts[:date]
          Chronic.parse(opts[:date])
        else
          Date.today
        end


      invoice = Invoice.create(
        :name => opts[:name],
        :created => date,
        :client => Client.get(opts[:client])
      )
      # Make active
      Invoice.current = invoice.id
      puts "Created invoice ##{invoice.id}"
    end
  end
end