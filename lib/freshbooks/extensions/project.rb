module FreshBooks
  Project = BaseObject.new(:project_id, :name, :bill_method, :client_id, :rate, :description)
  
  class Project
    TYPE_MAPPINGS = { 'project_id' => Fixnum, 'client_id' => Fixnum, 'rate' => Float }
    
    class << self
      def get(project_id)
        resp = FreshBooks.call_api('project.get', 'project_id' => project_id)
        return nil unless resp.success?
        new_from_xml(resp.elements[1])
      end
      
      def list(options = {})
        resp = FreshBooks.call_api('project.list', options)
        return nil unless resp.success?
        resp.elements.collect { |elem|  new_from_xml(elem) }
      end
      
      def find_by_name(name)
        list.detect { |p|  p.name == name }
      end
    end
    
    def create
      resp = FreshBooks.call_api('project.create', 'project' => self)
      if resp.success?
        self.project_id = resp.elements[1].to_i
      end
    end
    
    def update
      resp = FreshBooks.call_api('project.update', 'project' => self)
      resp.success?
    end
    
    def client
      Client.get(client_id)
    end
    
    def tasks
      Task.list('project_id' => project_id)
    end
    
    def time_entries
      TimeEntry.list('project_id' => project_id)
    end
  end
end
