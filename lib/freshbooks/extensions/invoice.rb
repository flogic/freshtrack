module FreshBooks
  class Invoice
    def open?
      !%w[draft paid].include?(status)
    end
  end
end
