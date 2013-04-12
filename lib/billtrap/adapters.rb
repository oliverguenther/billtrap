module BillTrap
  module Adapters
    extend self

    def load_adapter name
      adapter = name.downcase
      require "adapters/#{adapter}"
      # Try to load the adapter
      BillTrap::Adapters.const_get(adapter.classify)
    end
  end
end
