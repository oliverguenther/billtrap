  Sequel.migration do
  change do
    # Create clients table
    create_table(:clients) do
      primary_key :id
      String :firstname
      String :surname
      String :company
      String :address , :text => true
      String :mail
      Integer :rate
      String :currency
    end

    create_table(:invoices) do
      primary_key :id
      foreign_key :client_id, :clients
      String :name
      Date :created
      Date :sent
      String :attributes, :text => true, :default => '{}'
    end

    create_table(:invoice_entries) do
      primary_key :id
      foreign_key :invoice_id, :invoices
      String :title, :null => false
      String :notes, :text => true
      Date :date
      String :unit, :size => 10
      Float :count
      Integer :cents
    end

    create_table(:payments) do
      primary_key :id
      foreign_key :invoice_id, :invoices
      Integer :cents
      String :note, :text => true
    end

    create_table(:meta) do
      primary_key :id
      String :key
      String :value
    end
  end
end