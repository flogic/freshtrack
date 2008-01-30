require 'date'

module FreshBooks
  class BaseObject
    MAPPING_FNS[Date] = lambda { |xml_val|  Date.parse(xml_val.text) }
  end
end
