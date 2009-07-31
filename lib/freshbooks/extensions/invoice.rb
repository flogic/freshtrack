module FreshBooks
  class Invoice
    TYPE_MAPPINGS['date'] = Date
    
    def open?
      !%w[draft paid].include?(status)
    end
    
    def client
      Client.get(client_id)
    end
  end
end
