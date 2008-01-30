$:.unshift File.dirname(__FILE__)
require 'freshbooks/extensions'
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
  end
end
