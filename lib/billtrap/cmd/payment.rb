module BillTrap
  module CLI
    def payment
      opts = Trollop::options args do
        opt :add, "Add payment to current invoice", :type => :strings, :multi => true, :short => '-a'
        opt :delete, "Delete payment by ID from current invoice", :type => :int, :short => '-d'
      end
      if opts[:add_given] && opts[:add][0].length > 1
        # If the invoice has no total
        if Invoice.current.total.cents == 0
          warn "Can't add payment. Invoice ##{Invoice.current.id} has no total"
          return
        end

        # Test if payment would add more than the remaining amount
        payment = Money.parse(opts[:add][0].shift, Invoice.current.currency)
        if (Invoice.current.received_amount + payment > Invoice.current.total)
          warn 'With this payment, the received amount surpasses its total.'
          cropped = Invoice.current.total - Invoice.current.received_amount
          if ask_value "Do you want to add the remaining payment of #{format_money(cropped)}"
            payment = cropped
          else
            puts "Payment has NOT been added."
            return
          end
        end
        Invoice.current.add_payment(:cents => payment.cents, :note => opts[:add][0].shift)
        puts "Added #{format_money(payment)} to current invoice"
      elsif opts[:delete]
        if e = Payment[opts[:delete]]
          if confirm "Are you sure you want to delete Payment ##{e.id}"
            e.destroy
            puts "Payment has been removed."
          else
            puts "Payment has NOT been removed."
          end        
        else
          warn "Error: No Payment found for id ##{opts[:delete]}"
        end
      else
        warn "Error: Invalid command"
      end
    end
  end
end