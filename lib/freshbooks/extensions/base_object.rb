require 'date'

module FreshBooks
  class BaseObject
    MAPPING_FNS[Date] = lambda { |xml_val|  Date.parse(xml_val.text) }
    MAPPING_FNS[:boolean] = lambda do |xml_val|
      case xml_val.text
        when '0' : false
        when '1' : true
      end
    end

    def to_xml
      # The root element is the elem name
      root = Element.new elem_name

      # Add each BaseObject member to the root elem

      self.included_members.each do |field_name|

        value = self.send(field_name)

        if value.is_a?(Array)
          node = root.add_element(field_name)
          value.each { |array_elem| node.add_element(array_elem.to_xml) }
        elsif !value.nil?
          root.add_element(field_name).text = value
        end
      end
      root
    end

    # The root element is the class name, downcased (and underscored if there is any CamelCase)
    def elem_name
      elem_name = self.class.to_s.split('::').last.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
    end

    def included_members
      members - excluded_members
    end

    def excluded_members
      return [] unless self.class.const_defined?(:EXCLUDE_XML_ATTRIBUTES)
      self.class.const_get(:EXCLUDE_XML_ATTRIBUTES)
    end
  end
end
