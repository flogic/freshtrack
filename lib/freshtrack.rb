$:.unshift File.dirname(__FILE__)
require 'freshbooks/extensions'
require 'freshtrack/core_ext'
require 'yaml'

module Freshtrack
  class << self
    attr_reader :config, :project, :task
    
    def init
      load_config
      FreshBooks.setup("#{company}.freshbooks.com", token)
    end
    
    def load_config
      @config = YAML.load(File.read(File.expand_path('~/.freshtrack.yml')))
    end
    
    def company
      config['company']
    end
    
    def token
      config['token']
    end
    
    def project_task_mapping
      config['project_task_mapping']
    end
    
    def get_project_data(project_name)
      raise unless mapping = project_task_mapping[project_name]
      @project = FreshBooks::Project.find_by_name(mapping[:project])
      raise unless @project
      @task = FreshBooks::Task.find_by_name(mapping[:task])
      raise unless @task
    end
    
    def get_time_data(project_name)
      time_data = IO.read("| punch list #{project_name}")
      convert_time_data(time_data)
    end
    
    def convert_time_data(time_data)
      raw = YAML.load(time_data)
      condense_time_data(raw)
    end
    
    def condense_time_data(time_data)
      times_to_dates(time_data)
    end
    
    def times_to_dates(time_data)
      time_data.each do |td|
        punch_in  = td.delete('in')
        punch_out = td.delete('out')
        
        td['date']  = punch_in.to_date
        td['hours'] = (punch_out - punch_in).secs_to_hours
      end
    end
    
    def get_data(project_name)
      get_project_data(project_name)
      get_time_data(project_name)
    end
  end
end
