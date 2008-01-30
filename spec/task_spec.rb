require File.dirname(__FILE__) + '/spec_helper.rb'

describe FreshBooks::Task do
  before :each do
    @task = FreshBooks::Task.new
  end
  
  describe 'attributes' do
    it 'should have a task_id' do
      @task.should respond_to(:task_id)
    end
    
    it 'should have a name' do
      @task.should respond_to(:name)
    end
    
    it 'should have billable' do
      @task.should respond_to(:billable)
    end
    
    it 'should have a rate' do
      @task.should respond_to(:rate)
    end
    
    it 'should have a description' do
      @task.should respond_to(:description)
    end
  end
  
  describe 'type mappings' do
    before :each do
      @mapping = FreshBooks::Task::TYPE_MAPPINGS
    end
    
    it 'should map task_id to Fixnum' do
      @mapping['task_id'].should == Fixnum
    end
    
    it 'should map rate to Float' do
      @mapping['rate'].should == Float
    end
  end
  
  describe 'creating an instance' do
    before :each do
      @response = stub('response', :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    it 'should issue a request with the instance' do
      FreshBooks.expects(:call_api).with('task.create', 'task' => @task).returns(@response)
      @task.create
    end
    
    describe 'with a successful request' do
      before :each do
        @task_id = 5
        @response.stubs(:elements).returns([stub('pre element'), stub('element', :text => @task_id.to_s), stub('post element')])
        @response.stubs(:success?).returns(true)
      end
      
      it 'should set the ID from the response' do
        @task.expects(:task_id=).with(@task_id)
        @task.create
      end
      
      it 'should return the ID' do
        @task.create.should == @task_id
      end
    end
    
    describe 'with an unsuccessful request' do
      before :each do
        @response.stubs(:success?).returns(false)
      end
      
      it 'should not set the ID' do
        @task.expects(:task_id=).never
        @task.create
      end
      
      it 'should return nil' do
        @task.create.should be_nil
      end
    end
  end
  
  describe 'updating an instance' do
    before :each do
      @response = stub('response', :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    it 'should issue a request with the instance' do
      FreshBooks.expects(:call_api).with('task.update', 'task' => @task).returns(@response)
      @task.update
    end
    
    describe 'with a successful request' do
      before :each do
        @response.stubs(:success?).returns(true)
      end
      
      it 'should return true' do
        @task.update.should be(true)
      end
    end
    
    describe 'with an unsuccessful request' do
      before :each do
        @response.stubs(:success?).returns(false)
      end
      
      it 'should return false' do
        @task.update.should be(false)
      end
    end
  end
  
  describe 'deleting an instance' do
    before :each do
      @task_id = '5'
      @response = stub('response', :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    describe 'from the class' do
      it 'should require an argument' do
        lambda { FreshBooks::Task.delete }.should raise_error(ArgumentError)
      end
      
      it 'should accept an argument' do
        lambda { FreshBooks::Task.delete('arg') }.should_not raise_error(ArgumentError)
      end
      
      it 'should issue a request with the supplied ID' do
        FreshBooks.expects(:call_api).with('task.delete', 'task_id' => @task_id).returns(@response)
        FreshBooks::Task.delete(@task_id)
      end
      
      describe 'with a successful request' do
        before :each do
          @response.stubs(:success?).returns(true)
        end
        
        it 'should return true' do
          FreshBooks::Task.delete(@task_id).should be(true)
        end
      end
      
      describe 'with an unsuccessful request' do
        before :each do
          @response.stubs(:success?).returns(false)
        end
        
        it 'should return false' do
          FreshBooks::Task.delete(@task_id).should be(false)
        end
      end
    end
    
    describe 'from the instance' do
      before :each do
        @task.stubs(:task_id).returns(@task_id)
        FreshBooks::Task.stubs(:delete)
      end
      
      it 'should delegate to the class' do
        FreshBooks::Task.expects(:delete)
        @task.delete
      end
      
      it 'should pass its ID to the class method' do
        FreshBooks::Task.expects(:delete).with(@task_id)
        @task.delete
      end
      
      it 'should return the result from the class method' do
        val = stub('return val')
        FreshBooks::Task.stubs(:delete).returns(val)
        @task.delete.should == val
      end
    end
  end
  
  describe 'getting an instance' do
    before :each do
      @task_id = 1
      @element = stub('element')
      @response = stub('response', :elements => [stub('pre element'), @element, stub('post element')], :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    it 'should require an argument' do
      lambda { FreshBooks::Task.get }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::Task.get(@task_id) }.should_not raise_error(ArgumentError)
    end
    
    it 'should issue a request for the supplied ID' do
      FreshBooks.expects(:call_api).with('task.get', 'task_id' => @task_id).returns(@response)
      FreshBooks::Task.get(@task_id)
    end
    
    describe 'with a successful request' do
      before :each do
        @response.stubs(:success?).returns(true)
      end
      
      it 'should instantiate a new task instance from the request' do
        FreshBooks::Task.expects(:new_from_xml).with(@element)
        FreshBooks::Task.get(@task_id)
      end
      
      it 'should return the task instance' do
        val = stub('return val')
        FreshBooks::Task.stubs(:new_from_xml).returns(val)
        FreshBooks::Task.get(@task_id).should == val
      end
    end
    
    describe 'with an unsuccessful request' do
      before :each do
        @response.stubs(:success?).returns(false)
      end
      
      it 'should return nil' do
        FreshBooks::Task.get(@task_id).should be_nil
      end
    end
  end
  
  describe 'getting a list' do
    before :each do
      @task_id = 1
      @elements = Array.new(3) { stub('element') }
      @response = stub('response', :elements => @elements, :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    it 'should not require an argument' do
      lambda { FreshBooks::Task.list }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::Task.list('arg') }.should_not raise_error(ArgumentError)
    end
    
    it 'should issue a request for the task list' do
      FreshBooks.expects(:call_api).with('task.list', {}).returns(@response)
      FreshBooks::Task.list
    end
    
    it 'should pass the argument to the request' do
      arg = stub('arg')
      FreshBooks.expects(:call_api).with('task.list', arg).returns(@response)
      FreshBooks::Task.list(arg)
    end
    
    describe 'with a successful request' do
      before :each do
        @response.stubs(:success?).returns(true)
      end
      
      it 'should instantiate new task instances from the request' do
        @elements.each do |element|
          FreshBooks::Task.expects(:new_from_xml).with(element)
        end
        FreshBooks::Task.list
      end
      
      it 'should return the task instances' do
        vals = Array.new(@elements.length) { stub('return val') }
        @elements.each_with_index do |element, i|
          FreshBooks::Task.stubs(:new_from_xml).with(element).returns(vals[i])
        end
        FreshBooks::Task.list.should == vals
      end
    end
    
    describe 'with an unsuccessful request' do
      before :each do
        @response.stubs(:success?).returns(false)
      end
      
      it 'should return nil' do
        FreshBooks::Task.list.should be_nil
      end
    end
  end
  
  describe 'getting by name' do
    before :each do
      @name = 'taskname'
      FreshBooks::Task.stubs(:list).returns([])
    end
    
    it 'should require an argument' do
      lambda { FreshBooks::Task.find_by_name }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::Task.find_by_name(@name) }.should_not raise_error(ArgumentError)
    end
    
    it 'should return the task with a matching name' do
      tasks = Array.new(3) { |i| stub('task', :name => "task #{i}" ) }
      tasks[1,0] = expected = stub('task', :name => @name)
      FreshBooks::Task.stubs(:list).returns(tasks)
      FreshBooks::Task.find_by_name(@name).should == expected
    end
    
    it 'should return the first task found whose name matches' do
      tasks = Array.new(3) { |i| stub('task', :name => "task #{i}" ) }
      tasks[1,0] = expected = stub('task', :name => @name)
      tasks[3,0] = stub('task', :name => @name)
      FreshBooks::Task.stubs(:list).returns(tasks)
      FreshBooks::Task.find_by_name(@name).should == expected
    end
    
    it 'should return nil if no task with matching name found' do
      tasks = Array.new(3) { |i| stub('task', :name => "task #{i}" ) }
      FreshBooks::Task.stubs(:list).returns(tasks)
      FreshBooks::Task.find_by_name(@name).should be_nil
    end
  end
  
  it 'should have time entries' do
    @task.should respond_to(:time_entries)
  end
  
  describe 'time entries' do
    it 'should list time entries based on task ID' do
      task_id = stub('task ID')
      @task.stubs(:task_id).returns(task_id)
      FreshBooks::TimeEntry.expects(:list).with('task_id' => task_id)
      @task.time_entries
    end
    
    it 'should return found time entries' do
      time_entries = stub('time entries')
      task_id = stub('task ID')
      @task.stubs(:task_id).returns(task_id)
      FreshBooks::TimeEntry.stubs(:list).with('task_id' => task_id).returns(time_entries)
      @task.time_entries.should == time_entries
    end
  end
end
