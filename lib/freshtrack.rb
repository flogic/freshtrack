$:.unshift File.dirname(__FILE__)
require 'freshbooks/extensions'
require 'freshtrack/core_ext'
require 'yaml'

module Freshtrack
  class << self
    attr_reader :config, :project_name, :project, :task
    
    def init(project = nil)
      load_config
      @project_name = project
      FreshBooks.setup("#{company}.freshbooks.com", token)
    end
    
    def load_config
      @config = YAML.load(File.read(File.expand_path('~/.freshtrack.yml')))
    end
    
    def company
      return config['company'] unless project_name
      info = project_task_mapping[project_name]
      return config['company'] unless info[:company] and info[:token]
      info[:company]
    end
    
    def token
      return config['token'] unless project_name
      info = project_task_mapping[project_name]
      return config['token'] unless info[:company] and info[:token]
      info[:token]
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
    
    def get_data(project_name, options = {})
      get_project_data(project_name)
      collector(options).get_time_data(project_name)
    end
    
    def track(project_name, options = {})
      data = get_data(project_name, options)
      data.each do |entry_data|
        create_entry(entry_data)
      end
    end
    
    def create_entry(entry_data)
      time_entry = FreshBooks::TimeEntry.new
      
      time_entry.project_id = project.project_id
      time_entry.task_id    = task.task_id
      time_entry.date       = entry_data['date']
      time_entry.hours      = entry_data['hours']
      time_entry.notes      = entry_data['notes']
      
      result = time_entry.create
      
      if result
        true
      else
        STDERR.puts "warning: unsuccessful time entry creation for date #{entry_data['date']}"
        nil
      end
    end
    
    def collector(options = {})
      collector_name = config['collector']
      class_name = collector_name.capitalize.gsub(/([a-z])_([a-z])/) { "#{$1}#{$2.upcase}" }
      require "freshtrack/time_collectors/#{collector_name}"
      klass = Freshtrack::TimeCollector.const_get(class_name)
      klass.new(options)
    end
    
    def open_invoices
      invoices = FreshBooks::Invoice.list || []
      invoices.select { |i|  i.open? }
    end
    
    def invoice_aging
      open_invoices.collect do |i|
        {
          :id     => i.invoice_id,
          :number => i.number,
          :client => i.client.organization,
          :age    => Date.today - i.date,
          :status => i.status,
          :amount => i.amount,
          :owed   => i.owed_amount
        }
      end
    end
  end
end
