module BillTrap
  module Adapters
    class Ooffice
      # uses Serenity for ODT output
      include ::Serenity::Generator
      include BillTrap::Helpers
      attr_reader :id

      def initialize attributes
        attributes.each do |key, val|
          # slurp attributes into instances variables
          instance_variable_set("@#{key}", val)
        end
      end

      def generate
        date = @invoice[:created]
        output_path = "#{Config['billtrap_archive']}/#{date.year}/#{date.month}/#{date.mday}"
        FileUtils.mkpath(output_path)

        render_odt Config['serenity_template'], "#{output_path}/#{@invoice.id}.odt"
        puts "Generated invoice has been output to: #{output_path}/#{@invoice.id}.odt"
    end

  end
end
end
