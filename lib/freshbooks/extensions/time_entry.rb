module FreshBooks
  TimeEntry = BaseObject.new(:time_entry_id, :project_id, :task_id, :hours, :date, :notes)
  
  class TimeEntry
    TYPE_MAPPINGS = {
      'time_entry_id' => Fixnum, 'project_id' => Fixnum, 'task_id' => Fixnum,
      'hours' => Float, 'date' => Date
    }
    
    class << self
      def get(time_entry_id)
        resp = FreshBooks.call_api('time_entry.get', 'time_entry_id' => time_entry_id)
        return nil unless resp.success?
        new_from_xml(resp.elements[1])
      end
      
      def list(options = {})
        resp = FreshBooks.call_api('time_entry.list', options)
        return nil unless resp.success?
        resp.elements.collect { |elem|  new_from_xml(elem) }
      end
      
      def delete(time_entry_id)
        resp = FreshBooks.call_api('time_entry.delete', 'time_entry_id' => time_entry_id)
        resp.success?
      end
    end
    
    def create
      resp = FreshBooks.call_api('time_entry.create', 'time_entry' => self)
      if resp.success?
        self.time_entry_id = resp.elements[1].text.to_i
      end
    end
    
    def update
      resp = FreshBooks.call_api('time_entry.update', 'time_entry' => self)
      resp.success?
    end
    
    def delete
      self.class.delete(time_entry_id)
    end
    
    def task
      Task.get(task_id)
    end
    
    def project
      Project.get(project_id)
    end
  end
end
