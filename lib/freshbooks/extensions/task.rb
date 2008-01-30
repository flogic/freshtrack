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
        resp.elements.collect { |elem|  new_from_xml(elem) }
      end
      
      def find_by_name(name)
        list.detect { |p|  p.name == name }
      end
    end
  end
end
