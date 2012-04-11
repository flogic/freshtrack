module Freshtrack
  module TimeCollector
    module PunchyTemplate
      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      def condense_time_data(time_data)
        date_data = times_to_dates(time_data)
        group_date_data(date_data)
      end

      def times_to_dates(time_data)
        time_data.collect do |td|
          punch_in  = td.delete('in')
          punch_out = td.delete('out')

          if punch_out
            td['date']  = punch_in.to_date
            td['hours'] = (punch_out - punch_in).secs_to_hours
            td
          end
        end.compact
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
    end
  end
end
