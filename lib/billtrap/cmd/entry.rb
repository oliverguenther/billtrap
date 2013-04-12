module BillTrap
  module CLI
    def entry
      opts = Trollop::options args do
        opt :add, "Manually add entry to current invoice", :short => '-a'
        opt :delete, "Delete entry from current invoice by ID", :type => :int, :short => '-d'
      end
      current = Invoice.current
      if opts[:add]
        title = ask_value 'Entry title'
        date  = ask_value 'Entry date (YYYY-MM-DD)'
        unit  = ask_value "Displayed unit (Defaults to 'h' for hours)" || 'h'
        count = ask_value "Quantity (Numeric)"
        price = ask_value "Price in #{current.currency} per unit (Numeric)"
        notes = ask_value 'Optional Notes', true

        e = InvoiceEntry.create(
          :invoice_id => current.id,
          :title => title,
          :date => Date.parse(date),
          :unit => unit,
          :count => count,
          :notes => notes,
          :cents => Money.parse(price).cents
        ) 

        puts "Added entry (##{e.id}) to current invoice (ID #{current.id})"
      elsif name = opts[:name]
        Invoice.current.update(:name => name)
        puts "Set current invoice (##{Invoice.current.id}) name to: #{name}"
      elsif id = opts[:delete]
        if e = InvoiceEntry[id]
          if confirm "Are you sure you want to delete InvoiceEntry ##{e.id}"
            e.destroy
            puts "Entry has been removed."
          else
            puts "Entry has NOT been removed."
          end
        else
          warn "Can't find entry with id '#{id}'"
        end
      end
    end
  end
end