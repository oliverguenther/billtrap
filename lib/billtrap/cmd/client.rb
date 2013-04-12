module BillTrap
  module CLI
    def client
      opts = Trollop::options(args) do
        opt :add, "Add a new ID, reading from STDIN", :short => '-a'
        opt :delete, "Delete the client by ID", :type => Integer, :short => '-d'
      end

      if opts[:add]
        firstname = ask_value "First name"
        surname = ask_value "Surname"
        company = ask_value "Company"
        address = ask_value "Address", true
        mail = ask_value "Mail"
        rate = ask_value "Hourly rate"
        currency = ask_value "Use non-standard Currency? [Leave empty for #{BillTrap::Config['currency']}]"

        currency = currency.empty? ? BillTrap::Config['currency'] : currency
        puts "'#{currency}'"

        client = Client.create(
          :firstname => firstname, 
          :surname => surname, 
          :company => company,
          :address => address,
          :mail => mail,
          :rate => Money.parse(rate, currency).cents,
          :currency => currency
        )
          puts "Client #{firstname} #{surname} was created with id #{client.id}"
      elsif id = opts[:delete]
        if e = Client.get(id)
          if confirm "Are you sure you want to delete Client #{e.name} (##{e.id})"
            begin
              e.destroy
              puts "Client has been removed."
            rescue Sequel::ForeignKeyConstraintViolation
              warn 'Error: Client is still in use. Refusing to delete client'
            end
          else
            puts "Client has NOT been removed."
          end
        else
          warn "Can't find Client with id '#{id}'"
        end
      end
    end
    
  end
end