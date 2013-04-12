module BillTrap
  module CLI
    def import
      opts = Trollop::options args do
        opt :clear, "Clear entries before import", :short => '-c'
        opt :entry, "Import entries by ID", :type => :strings, :multi => true, :short => '-e'
        opt :round, "Round imported entries", :short => '-r'
        opt :sheet, "Import sheet by name", :type => :string, :short => '-s'
      end
      
      # Clear entries if --clear given
      if opts[:clear]
        InvoiceEntry.where(:invoice_id => Invoice.current.id).destroy
      end

      entries = 
      if opts[:sheet]
        Entry.filter(:sheet => opts[:sheet]).all
      elsif opts[:entry_given]
        Entry.where(:id => opts[:entry].first).all
      else 
        []
      end

      unless entries.length > 0
        warn "No matching entries found."
        return
      end

      entries.each do |e|
        Entry.round = opts[:round]
        # Ignore entry if (rounded) is empty
        next if e.duration == 0
        imported = InvoiceEntry.create(
          :invoice_id => Invoice.current.id,
          :title => e.sheet,
          :date => e.start.to_date,
          :unit => 'h',
          :count => (e.duration.to_f / 3600).round(2),
          :notes => e.note,
          :cents => Invoice.current.rate.cents
        ) 
        puts "Imported #{imported.count} hours from sheet #{e.sheet} as entry ##{imported.id}"
      end
    end
  end
end