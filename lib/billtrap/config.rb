module BillTrap
  module Config
    extend self

    CONFIG_PATH = File.join(BILLTRAP_HOME, 'billtrap.yml')

    # Application defaults.
    #
    # These are written to BILLTRAP_CONFIG_PATH or <HOME>/.billtrap/billtrap.yml by executing
    # <code>
    # billtrap configure
    # </code>
    def defaults
      {
        # Database identifier, defaults to 'sqlite://<BILLTRAP_HOME>/.billtrap.db'
        'database' => "sqlite://#{BILLTRAP_HOME}/billtrap.db",
        # Timetrap database, used to import Entries
        'timetrap_database' => "sqlite://#{ENV['HOME']}/.timetrap.db",
        # We'll also need the round specifier
        'round_in_seconds' => 900,
				# Path to invoice archive
				'billtrap_archive' => "#{ENV['HOME']}/Documents/billtrap/invoices",
        # Currency to use (see RubyMoney for codes)
        'currency' => 'USD',
        # Default rate in the above currency
        'default_rate' => '25.00',
				# Invoice numbering scheme
        # TODO possible values
				'invoice_number_format' => "%Y%m%d_%{invoice_id}",
        # Money formatter
        # See http://rubydoc.info/gems/money/Money/Formatting for options
        'currency_format' =>  { :with_currency => true , :symbol => false},
        # Date output format
        'date_format' => '%Y-%m-%d',
				# Due date in days
				'due_date' => 30,
        # Default invoice adapter to use when none is specified
        'default_formatter' => 'serenity',
        # Serenity adapter: Path to invoice template
        'serenity_template' => "#{BILLTRAP_HOME}/.billtrap_template.odt",
      }
    end

    def [](key)
      overrides = File.exist?(CONFIG_PATH) ? YAML.load(erb_render(File.read(CONFIG_PATH))) : {}
      defaults.merge(overrides)[key]
    rescue => e
      warn "invalid config file"
      warn e.message
      defaults[key]
    end

    def erb_render(content)
      ERB.new(content).result
    end

    def configure!
      configs = if File.exist?(CONFIG_PATH)
        defaults.merge(YAML.load_file(CONFIG_PATH))
      else
        defaults
      end
      File.open(CONFIG_PATH, 'w') do |fh|
        fh.puts(configs.to_yaml)
      end
    end
  end
end
