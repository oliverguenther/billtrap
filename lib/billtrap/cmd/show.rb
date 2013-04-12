module BillTrap
  module CLI
    def show
      opts = Trollop::options args do
        opt :completed, "Show only completed (i.e., sent and paid) invoices", :short => '-c'
        opt :detail, "Show details (including entries) of a particular invoice", :type => :string, :short => '-d'
      end
      if opts[:detail]
        # Display details of invoice with id/name from args
        if invoice = Invoice.get(opts[:detail])

          puts "%-12s%s" % ["Invoice: ", "#{invoice.name || 'unnamed'} (##{invoice.id})"]
          puts "%-12s%s" % ["Created on: ", format_date(invoice.created)]
          if invoice.sent
            puts "%-12s%s" % ["Sent on: ", format_date(invoice.sent)]
          end

          puts '-' * 22
          if invoice.invoice_entries.size > 0
            puts 'Invoice entries'
            # Determine length of entry titles
            width = invoice.invoice_entries.sort_by{|inv| inv.title.to_s.length }.last.title.to_s.length + 4
            width = 12 if width < 12
            puts "  %-#{width}s%-12s%-12s%-12s%s" % ["Title", "Date", "Quantity", "Price", "Notes"]
            invoice.invoice_entries.each do |e|
              puts "  %-#{width}s%-12s%-12s%-12s%s" % [
                e.title,
                e.date,
                e.typed_amount,
                format_money(e.total),
                e.notes
              ]
            end
          else
            puts 'No InvoiceEntries'
          end

          if invoice.payments.size > 0
            puts '-' * 22
            puts 'Received payments'
            puts "  %12s    %s" % ["Payment", "Notes"]
            invoice.payments.each do |e|
              puts "  %12s    %s" % [
                format_money(e.amount),
                e.note
              ]
            end
          else
          end

        else
          puts "No Invoice found for input '#{detail_id}'"
        end
      elsif opts[:completed]
        puts 'Showing only completed invoices'
        print_invoices Invoice.completed
      else
        puts 'Showing open invoices'
        print_invoices Invoice.open
      end
    end

    private
    def print_invoices invoices
      if invoices.empty?
        warn 'No matching invoices found'
        return
      end

      # Determine length of invoice names
      width = invoices.sort_by{|inv| inv.name.to_s.length }.last.name.to_s.length + 4
      width = 12 if width < 12
      puts " %-6s%-#{width}s%-24s%-16s%s" % ["ID", "Name", "Client", "Created", "Payments / Total"]
      invoices.each do |i|
        active = (Invoice.current.id == i.id) ? '>>' : ''
        puts " %-6s%-#{width}s%-24s%-16s%s" % [
          "#{active}#{i.id}",
          i.name || ' - ',
          i.client ? i.client.name : ' - ',
          i.created,
          "#{format_money(i.received_amount)} / #{format_money(i.total)}"
          ]
      end
    end

  end
end