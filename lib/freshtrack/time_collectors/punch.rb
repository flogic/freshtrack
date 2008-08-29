require 'freshtrack/time_collectors/punchy_template'

module Freshtrack
  module TimeCollector
    class Punch
      include PunchyTemplate
      
      def get_time_data(project)
        time_data = IO.read("| punch list #{project} #{option_str}")
        converted = convert_time_data(time_data)
        condense_time_data(converted)
      end
      
      def convert_time_data(time_data)
        YAML.load(time_data)
      end
      
      
      private
      
      def option_str
        options.collect { |key, val|  "--#{key} #{val.strftime('%Y-%m-%dT%H:%M:%S%z')}" }.join(' ')
      end
    end
  end
end
