module FreshBooks
  class Invoice
    TYPE_MAPPINGS['date'] = Date
    
    def open?
      !%w[draft paid].include?(status)
    end
    
    def client
      Client.get(client_id)
    end
    
    def payments
      Payment.list('invoice_id' => invoice_id) || []
    end
    
    def paid_amount
      payments.inject(0) { |sum, pay|  sum + pay.amount }
    end
    
    def owed_amount
      amount - paid_amount
    end
    
    attr_accessor :number
    
    alias_method :old_brackets, :[]
    def [](m)
      if m.to_s == 'number'
        self.number
      else
        old_brackets(m)
      end
    end

    alias_method :old_brackets_equal, :[]=
    def []=(m, v)
      if m.to_s == 'number'
        self.number = v 
      else
        old_brackets_equal(m, v)
      end
    end
    
    class << self
      alias_method :old_members, :members
      def members
        old_members + ['number']
      end
    end
  end
end
