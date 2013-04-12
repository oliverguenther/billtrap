module BillTrap
  module CLI
    def export
      opts = Trollop::options args do
        opt :adapter, "Set adapter", :type => :string, :short => '-a'
      end
      adapter = opts[:adapter] || 'ooffice'
      begin
        # Replace invoice number placeholders
        arg = {
          # Unique, auto-incremented invoice id (from database)
          :invoice_id => Invoice.current.id,
          # Unique, auto-incremented client id
          :client_id => Invoice.current.client_id
        }

        # Replace above parameters, then strfime parameters
        invoice_number = Invoice.current.created.strftime(Config['invoice_number_format'].gsub(/%\{(.*?)\}/) { arg[$1.to_sym] })

        attributes = {
          :invoice => Invoice.current,
          :invoice_number => invoice_number,
        }

        BillTrap::Adapters.load_adapter(adapter).new(attributes).generate
      rescue LoadError
        warn "Couldn't load adapter named #{adapter}.rb"
      end

    end
  end
end