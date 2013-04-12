module BillTrap
  module Helpers

    def is_i? val
      !!(val.is_a? Integer or val =~ /^\d+$/)
    end 

    def format_date d, format_str=BillTrap::Config['date_format']
      d.strftime(format_str)
    end

    def format_money m, opts=BillTrap::Config['currency_format']
      m.format(opts)
    end

  end
end
