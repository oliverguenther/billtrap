require 'sequel'
# uses json for serialization of
# custom invoice flags
require 'json'

# encoding: UTF-8
module BillTrap
  class Client < Sequel::Model
    extend Helpers
    one_to_many :invoices

    # Retrieve client
    # If numeric, assumes it's an ID
    # If string, returns first match c == surname
    # Returns nil otherwise / if no match was found
    def self.get c
      if is_i? c
        Client[c]
      elsif c.is_a? String
        Client.find(:surname => c)
      else
        nil
      end
    end


    def name
      "#{firstname} #{surname}"
    end

 end

 class Invoice < Sequel::Model
  extend Helpers

  # Associates to a client
  many_to_one :client

  # Associates to many InvoiceEntries
  one_to_many :invoice_entries

  # Associates to many Payments
  one_to_many :payments

  # Serialize custom flags
  plugin :serialization, :json, :attributes

  def self.open
    all.select { |i| !i.paid? }
  end

  def self.completed
    exclude(:sent => nil).all.select { |i| i.paid? }
  end

  # Retrieve invoice
  # If numeric, assumes it's an ID
  # If string, returns first match inv == name
  # Returns nil otherwise / if no match was found
  def self.get inv
    if is_i? inv
      Invoice[inv]
    elsif inv.is_a? String
      Invoice.find(:name => inv)
    else
      nil
    end
  end

  def self.current= id
    last = Meta.find_or_create(:key => 'current_invoice')
    last.value = id
    last.save
  end

  def self.current
    last = Meta.find(:key => 'current_invoice')
    Invoice[last.value]
  end

  def currency
    if client_id
      client.currency
    else
      BillTrap::Config['currency']
    end
  end

  def set_attr k,v
    attributes[k] = v
    save
  end

  def total
    sum = Money.new(0, currency)
    entries = InvoiceEntry.filter(:invoice_id=>id)
    entries.each do |entry|
      sum += entry.total
    end
    return sum
  end

  def paid?
    if sent.nil?
      return false
    end
    # TODO == vs. >= ?
    puts "received = #{received_amount}, total = #{total}"
    return received_amount == total
  end

  def rate
    rate = if client.nil?
      BillTrap::Config['default_rate']
    else
      client.rate
    end
    Money.parse(rate, currency)
  end


  def received_amount
    cents = Payment.where(:invoice_id => id).sum(:cents)
    Money.new(cents, currency)
  end

  def overdue?
    due_date > Date.today
  end

  def due_date
   created + BillTrap::Config['due_date']
 end

end

class InvoiceEntry < Sequel::Model

  # Associates with one invoice
  many_to_one :invoice

  def typed_amount
   return "#{count}#{unit}"
  end

  def total
    Money.new(cents, invoice.currency) * count
  end

end

class Payment < Sequel::Model

  # Associates with one invoice
  many_to_one :invoice

  def amount
    Money.new(cents, invoice.currency)
  end
end


class Entry < Sequel::Model(TT_DB)
  class << self
    attr_accessor :round
  end

  def round?
    !!self.class.round
  end

  def date
   start.to_date
  end

  def start= time
   self[:start]= Timer.process_time(time)
  end

  def end= time
    self[:end]= Timer.process_time(time)
  end

  def start
    round? ? rounded_start : self[:start]
  end

  def end
    round? ? rounded_end : self[:end]
  end

  def sheet
    self[:sheet].to_s
  end

  def duration
    @duration ||= self.end_or_now.to_i - self.start.to_i
  end

  def duration
    @rounded_duration ||= self.end_or_now.to_i - self.start.to_i
  end


  def end_or_now
    self.end || (round? ? round(Time.now) : Time.now)
  end

  def rounded_start
    round(self[:start])
  end

  def rounded_end
    round(self[:end])
  end

  def round time, roundsecs=BillTrap::Config['round_in_seconds']
    return nil unless time
    Time.at(
      if (r = time.to_i % roundsecs) < 450
        time.to_i - r
      else
        time.to_i + (roundsecs - r)
      end
      )
  end

  def self.sheets
    map{|e|e.sheet}.uniq.sort
  end

  end

  class Meta < Sequel::Model(:meta)
    def value
      self[:value].to_s
    end
  end
end
