module FreshBooks
  Task = BaseObject.new(:task_id, :name, :billable, :rate, :description)
  
  class Task
    TYPE_MAPPINGS = { 'task_id' => Fixnum, 'rate' => Float }
    
    class << self
      def get(task_id)
        resp = FreshBooks.call_api('task.get', 'task_id' => task_id)
        return nil unless resp.success?
        new_from_xml(resp.elements[1])
      end
      
      def list(options = {})
        resp = FreshBooks.call_api('task.list', options)
        return nil unless resp.success?
        list_elements = resp.elements[1].elements
        list_elements.collect { |elem|  new_from_xml(elem) }
      end
      
      def find_by_name(name)
        list.detect { |p|  p.name == name }
      end
      
      def delete(task_id)
        resp = FreshBooks.call_api('task.delete', 'task_id' => task_id)
        resp.success?
      end
    end
    
    def create
      resp = FreshBooks.call_api('task.create', 'task' => self)
      if resp.success?
        self.task_id = resp.elements[1].text.to_i
      end
    end
    
    def update
      resp = FreshBooks.call_api('task.update', 'task' => self)
      resp.success?
    end
    
    def delete
      self.class.delete(task_id)
    end
    
    def time_entries
      TimeEntry.list('task_id' => task_id)
    end
  end
end
