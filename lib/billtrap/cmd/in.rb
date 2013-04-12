module BillTrap
  module CLI
     def in
      key = args.shift || raise('Error: No ID/Name given')
      invoice = Invoice.get key

      if invoice
        puts "Activating invoice ##{invoice.id}"
        # set current id
        Invoice.current = invoice.id
      else
        puts "No Invoice found for input '#{key}'"
      end
    end 
  end
end