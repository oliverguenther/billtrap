module BillTrap
  module CLI
    def set
      # Grab subcommand
      k = args.shift
      case
      when k == 'client'
        id = args.shift
        if e = Client.get(id)
          Invoice.current.update(:client_id => e.id)
          puts "SET client to #{e.name} (##{e.id})"
        else
          warn "Error: Can't find Client with id '#{id}'"
        end
      when k == 'date'
        if d = args.shift
          new_date = Date.parse d
        else
          new_date = Date.today
        end
        Invoice.current.update(:created => new_date)
        puts "SET created date to #{format_date(new_date)}"
      when k == 'name'
        if n = args.shift
          Invoice.current.update(:name => n)
          puts "SET name to '#{n}'"
        else
          warn "Error: Missing required attributed for token 'name'"
        end
      when k == 'sent'
        if d = args.shift
          Invoice.current.update(:sent => Date.parse(d))
          puts "SET invoice sent date to #{d}"
        else
          Invoice.current.update(:sent => nil)
          puts "UNSET invoice sent date"
        end
      when k.respond_to?(:to_s)
        Invoice.current.set_attr(k.to_str, args.shift)
        puts "Setting attribute #{k}"
      else
        warn "Error: Missing / unrecognized TOKEN #{k}"
      end
    end
  end
end
