require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe FreshBooks::Task do
  before do
    @task = FreshBooks::Task.new
  end
  
  describe 'attributes' do
    it 'should have a task_id' do
      @task.should.respond_to(:task_id)
    end
    
    it 'should have a name' do
      @task.should.respond_to(:name)
    end
    
    it 'should have billable' do
      @task.should.respond_to(:billable)
    end
    
    it 'should have a rate' do
      @task.should.respond_to(:rate)
    end
    
    it 'should have a description' do
      @task.should.respond_to(:description)
    end
  end
  
  describe 'type mappings' do
    before do
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
    before do
      @response = mock('response', :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    it 'should issue a request with the instance' do
      FreshBooks.should.receive(:call_api).with('task.create', 'task' => @task).and_return(@response)
      @task.create
    end
    
    describe 'with a successful request' do
      before do
        @task_id = 5
        @response.stub!(:elements).and_return([mock('pre element'), mock('element', :text => @task_id.to_s), mock('post element')])
        @response.stub!(:success?).and_return(true)
      end
      
      it 'should set the ID from the response' do
        @task.should.receive(:task_id=).with(@task_id)
        @task.create
      end
      
      it 'should return the ID' do
        @task.create.should == @task_id
      end
    end
    
    describe 'with an unsuccessful request' do
      before do
        @response.stub!(:success?).and_return(false)
      end
      
      it 'should not set the ID' do
        @task.should.receive(:task_id=).never
        @task.create
      end
      
      it 'should return nil' do
        @task.create.should.be.nil
      end
    end
  end
  
  describe 'updating an instance' do
    before do
      @response = mock('response', :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    it 'should issue a request with the instance' do
      FreshBooks.should.receive(:call_api).with('task.update', 'task' => @task).and_return(@response)
      @task.update
    end
    
    describe 'with a successful request' do
      before do
        @response.stub!(:success?).and_return(true)
      end
      
      it 'should return true' do
        @task.update.should == true
      end
    end
    
    describe 'with an unsuccessful request' do
      before do
        @response.stub!(:success?).and_return(false)
      end
      
      it 'should return false' do
        @task.update.should == false
      end
    end
  end
  
  describe 'deleting an instance' do
    before do
      @task_id = '5'
      @response = mock('response', :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    describe 'from the class' do
      it 'should require an argument' do
        lambda { FreshBooks::Task.delete }.should.raise(ArgumentError)
      end
      
      it 'should accept an argument' do
        lambda { FreshBooks::Task.delete('arg') }.should.not.raise(ArgumentError)
      end
      
      it 'should issue a request with the supplied ID' do
        FreshBooks.should.receive(:call_api).with('task.delete', 'task_id' => @task_id).and_return(@response)
        FreshBooks::Task.delete(@task_id)
      end
      
      describe 'with a successful request' do
        before do
          @response.stub!(:success?).and_return(true)
        end
        
        it 'should return true' do
          FreshBooks::Task.delete(@task_id).should == true
        end
      end
      
      describe 'with an unsuccessful request' do
        before do
          @response.stub!(:success?).and_return(false)
        end
        
        it 'should return false' do
          FreshBooks::Task.delete(@task_id).should == false
        end
      end
    end
    
    describe 'from the instance' do
      before do
        @task.stub!(:task_id).and_return(@task_id)
        FreshBooks::Task.stub!(:delete)
      end
      
      it 'should delegate to the class' do
        FreshBooks::Task.should.receive(:delete)
        @task.delete
      end
      
      it 'should pass its ID to the class method' do
        FreshBooks::Task.should.receive(:delete).with(@task_id)
        @task.delete
      end
      
      it 'should return the result from the class method' do
        val = mock('return val')
        FreshBooks::Task.stub!(:delete).and_return(val)
        @task.delete.should == val
      end
    end
  end
  
  describe 'getting an instance' do
    before do
      @task_id = 1
      @element = mock('element')
      @response = mock('response', :elements => [mock('pre element'), @element, mock('post element')], :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    it 'should require an argument' do
      lambda { FreshBooks::Task.get }.should.raise(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::Task.get(@task_id) }.should.not.raise(ArgumentError)
    end
    
    it 'should issue a request for the supplied ID' do
      FreshBooks.should.receive(:call_api).with('task.get', 'task_id' => @task_id).and_return(@response)
      FreshBooks::Task.get(@task_id)
    end
    
    describe 'with a successful request' do
      before do
        @response.stub!(:success?).and_return(true)
      end
      
      it 'should instantiate a new task instance from the request' do
        FreshBooks::Task.should.receive(:new_from_xml).with(@element)
        FreshBooks::Task.get(@task_id)
      end
      
      it 'should return the task instance' do
        val = mock('return val')
        FreshBooks::Task.stub!(:new_from_xml).and_return(val)
        FreshBooks::Task.get(@task_id).should == val
      end
    end
    
    describe 'with an unsuccessful request' do
      before do
        @response.stub!(:success?).and_return(false)
      end
      
      it 'should return nil' do
        FreshBooks::Task.get(@task_id).should.be.nil
      end
    end
  end
  
  describe 'getting a list' do
    before do
      @task_id = 1
      @elements = Array.new(3) { mock('list element') }
      @response = mock('response', :elements => [mock('pre element'), mock('element', :elements => @elements), mock('post element')], :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    it 'should not require an argument' do
      lambda { FreshBooks::Task.list }.should.not.raise(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::Task.list('arg') }.should.not.raise(ArgumentError)
    end
    
    it 'should issue a request for the task list' do
      FreshBooks.should.receive(:call_api).with('task.list', {}).and_return(@response)
      FreshBooks::Task.list
    end
    
    it 'should pass the argument to the request' do
      arg = mock('arg')
      FreshBooks.should.receive(:call_api).with('task.list', arg).and_return(@response)
      FreshBooks::Task.list(arg)
    end
    
    describe 'with a successful request' do
      before do
        @response.stub!(:success?).and_return(true)
      end
      
      it 'should instantiate new task instances from the request' do
        @elements.each do |element|
          FreshBooks::Task.should.receive(:new_from_xml).with(element)
        end
        FreshBooks::Task.list
      end
      
      it 'should return the task instances' do
        vals = Array.new(@elements.length) { mock('return val') }
        @elements.each_with_index do |element, i|
          FreshBooks::Task.stub!(:new_from_xml).with(element).and_return(vals[i])
        end
        FreshBooks::Task.list.should == vals
      end
    end
    
    describe 'with an unsuccessful request' do
      before do
        @response.stub!(:success?).and_return(false)
      end
      
      it 'should return nil' do
        FreshBooks::Task.list.should.be.nil
      end
    end
  end
  
  describe 'getting by name' do
    before do
      @name = 'taskname'
      FreshBooks::Task.stub!(:list).and_return([])
    end
    
    it 'should require an argument' do
      lambda { FreshBooks::Task.find_by_name }.should.raise(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::Task.find_by_name(@name) }.should.not.raise(ArgumentError)
    end
    
    it 'should return the task with a matching name' do
      tasks = Array.new(3) { |i| mock('task', :name => "task #{i}" ) }
      tasks[1,0] = expected = mock('task', :name => @name)
      FreshBooks::Task.stub!(:list).and_return(tasks)
      FreshBooks::Task.find_by_name(@name).should == expected
    end
    
    it 'should return the first task found whose name matches' do
      tasks = Array.new(3) { |i| mock('task', :name => "task #{i}" ) }
      tasks[1,0] = expected = mock('task', :name => @name)
      tasks[3,0] = mock('task', :name => @name)
      FreshBooks::Task.stub!(:list).and_return(tasks)
      FreshBooks::Task.find_by_name(@name).should == expected
    end
    
    it 'should return nil if no task with matching name found' do
      tasks = Array.new(3) { |i| mock('task', :name => "task #{i}" ) }
      FreshBooks::Task.stub!(:list).and_return(tasks)
      FreshBooks::Task.find_by_name(@name).should.be.nil
    end
  end
  
  it 'should have time entries' do
    @task.should.respond_to(:time_entries)
  end
  
  describe 'time entries' do
    it 'should list time entries based on task ID' do
      task_id = mock('task ID')
      @task.stub!(:task_id).and_return(task_id)
      FreshBooks::TimeEntry.should.receive(:list).with('task_id' => task_id)
      @task.time_entries
    end
    
    it 'should return found time entries' do
      time_entries = mock('time entries')
      task_id = mock('task ID')
      @task.stub!(:task_id).and_return(task_id)
      FreshBooks::TimeEntry.stub!(:list).with('task_id' => task_id).and_return(time_entries)
      @task.time_entries.should == time_entries
    end
  end
end
