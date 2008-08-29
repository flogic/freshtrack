require 'freshtrack/time_collectors/punchy_template'
require 'punch'

module Freshtrack
  module TimeCollector
    class OneInchPunch
      include PunchyTemplate
      
      def get_time_data(project)
        ::Punch.load
        time_data = ::Punch.list(project, options)
        condense_time_data(time_data)
      end
    end
  end
end
