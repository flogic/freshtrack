module FreshBooks
  class Invoice
    TYPE_MAPPINGS['date'] = Date
    
    def open?
      !%w[draft paid].include?(status)
    end
  end
end
