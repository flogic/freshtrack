module Freshtrack
  module TimeCollector
    class Punch
      attr_reader :options
      
      def initialize(options = {})
        @options = options
      end
      
      def get_time_data(project)
        time_data = IO.read("| punch list #{project} #{option_str}")
        converted = convert_time_data(time_data)
        condense_time_data(converted)
      end
      
      def convert_time_data(time_data)
        YAML.load(time_data)
      end
      
      def condense_time_data(time_data)
        date_data = times_to_dates(time_data)
        group_date_data(date_data)
      end
      
      def times_to_dates(time_data)
        time_data.each do |td|
          punch_in  = td.delete('in')
          punch_out = td.delete('out')

          td['date']  = punch_in.to_date
          td['hours'] = (punch_out - punch_in).secs_to_hours
        end
      end
      
      def group_date_data(date_data)
        separator = '-' * 20
        grouped = date_data.group_by { |x|  x['date'] }
        grouped.sort.inject([]) do |arr, (date, data)|
          this_date = { 'date' => date }
          this_date['hours'] = data.inject(0) { |sum, x|  sum + x['hours'] }
          this_date['hours'] = ('%.2f' % this_date['hours']).to_f
          this_date['notes'] = data.collect { |x|  x['log'].join("\n") }.join("\n" + separator + "\n")
          arr + [this_date]
        end
      end
      
      
      private
      
      def option_str
        options.collect { |key, val|  "--#{key} #{val.strftime('%Y-%m-%dT%H:%M:%S%z')}" }.join(' ')
      end
    end
  end
end
