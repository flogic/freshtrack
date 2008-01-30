require File.dirname(__FILE__) + '/spec_helper.rb'

describe FreshBooks::TimeEntry do
  before :each do
    @time_entry = FreshBooks::TimeEntry.new
  end
  
  describe 'attributes' do
    it 'should have a time_entry_id' do
      @time_entry.should respond_to(:time_entry_id)
    end
    
    it 'should have a project_id' do
      @time_entry.should respond_to(:project_id)
    end
    
    it 'should have a task_id' do
      @time_entry.should respond_to(:task_id)
    end
    
    it 'should have hours' do
      @time_entry.should respond_to(:hours)
    end
    
    it 'should have a date' do
      @time_entry.should respond_to(:date)
    end
    
    it 'should have notes' do
      @time_entry.should respond_to(:notes)
    end
  end
  
  describe 'type mappings' do
    before :each do
      @mapping = FreshBooks::TimeEntry::TYPE_MAPPINGS
    end
    
    it 'should map time_entry_id to Fixnum' do
      @mapping['time_entry_id'].should == Fixnum
    end
    
    it 'should map project_id to Fixnum' do
      @mapping['project_id'].should == Fixnum
    end
    
    it 'should map task_id to Fixnum' do
      @mapping['task_id'].should == Fixnum
    end
    
    it 'should map hours to Float' do
      @mapping['hours'].should == Float
    end
    
    it 'should map date to Date' do
      @mapping['date'].should == Date
    end
  end
  
  describe 'creating an instance' do
    before :each do
      @response = stub('response', :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    it 'should issue a request with the instance' do
      FreshBooks.expects(:call_api).with('time_entry.create', 'time_entry' => @time_entry).returns(@response)
      @time_entry.create
    end
    
    describe 'with a successful request' do
      before :each do
        @time_entry_id = 5
        @response.stubs(:elements).returns([stub('pre element'), stub('element', :text => @time_entry_id.to_s), stub('post element')])
        @response.stubs(:success?).returns(true)
      end
      
      it 'should set the ID from the response' do
        @time_entry.expects(:time_entry_id=).with(@time_entry_id)
        @time_entry.create
      end
      
      it 'should return the ID' do
        @time_entry.create.should == @time_entry_id
      end
    end
    
    describe 'with an unsuccessful request' do
      before :each do
        @response.stubs(:success?).returns(false)
      end
      
      it 'should not set the ID' do
        @time_entry.expects(:time_entry_id=).never
        @time_entry.create
      end
      
      it 'should return nil' do
        @time_entry.create.should be_nil
      end
    end
  end
  
  describe 'updating an instance' do
    before :each do
      @response = stub('response', :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    it 'should issue a request with the instance' do
      FreshBooks.expects(:call_api).with('time_entry.update', 'time_entry' => @time_entry).returns(@response)
      @time_entry.update
    end
    
    describe 'with a successful request' do
      before :each do
        @response.stubs(:success?).returns(true)
      end
      
      it 'should return true' do
        @time_entry.update.should be(true)
      end
    end
    
    describe 'with an unsuccessful request' do
      before :each do
        @response.stubs(:success?).returns(false)
      end
      
      it 'should return false' do
        @time_entry.update.should be(false)
      end
    end
  end
  
  describe 'deleting an instance' do
    before :each do
      @time_entry_id = '5'
      @response = stub('response', :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    describe 'from the class' do
      it 'should require an argument' do
        lambda { FreshBooks::TimeEntry.delete }.should raise_error(ArgumentError)
      end
      
      it 'should accept an argument' do
        lambda { FreshBooks::TimeEntry.delete('arg') }.should_not raise_error(ArgumentError)
      end
      
      it 'should issue a request with the supplied ID' do
        FreshBooks.expects(:call_api).with('time_entry.delete', 'time_entry_id' => @time_entry_id).returns(@response)
        FreshBooks::TimeEntry.delete(@time_entry_id)
      end
      
      describe 'with a successful request' do
        before :each do
          @response.stubs(:success?).returns(true)
        end
        
        it 'should return true' do
          FreshBooks::TimeEntry.delete(@time_entry_id).should be(true)
        end
      end
      
      describe 'with an unsuccessful request' do
        before :each do
          @response.stubs(:success?).returns(false)
        end
        
        it 'should return false' do
          FreshBooks::TimeEntry.delete(@time_entry_id).should be(false)
        end
      end
    end
    
    describe 'from the instance' do
      before :each do
        @time_entry.stubs(:time_entry_id).returns(@time_entry_id)
        FreshBooks::TimeEntry.stubs(:delete)
      end
      
      it 'should delegate to the class' do
        FreshBooks::TimeEntry.expects(:delete)
        @time_entry.delete
      end
      
      it 'should pass its ID to the class method' do
        FreshBooks::TimeEntry.expects(:delete).with(@time_entry_id)
        @time_entry.delete
      end
      
      it 'should return the result from the class method' do
        val = stub('return val')
        FreshBooks::TimeEntry.stubs(:delete).returns(val)
        @time_entry.delete.should == val
      end
    end
  end
  
  describe 'getting an instance' do
    before :each do
      @time_entry_id = 1
      @element = stub('element')
      @response = stub('response', :elements => [stub('pre element'), @element, stub('post element')], :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    it 'should require an argument' do
      lambda { FreshBooks::TimeEntry.get }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::TimeEntry.get(@time_entry_id) }.should_not raise_error(ArgumentError)
    end
    
    it 'should issue a request for the supplied ID' do
      FreshBooks.expects(:call_api).with('time_entry.get', 'time_entry_id' => @time_entry_id).returns(@response)
      FreshBooks::TimeEntry.get(@time_entry_id)
    end
    
    describe 'with a successful request' do
      before :each do
        @response.stubs(:success?).returns(true)
      end
      
      it 'should instantiate a new time_entry instance from the request' do
        FreshBooks::TimeEntry.expects(:new_from_xml).with(@element)
        FreshBooks::TimeEntry.get(@time_entry_id)
      end
      
      it 'should return the time_entry instance' do
        val = stub('return val')
        FreshBooks::TimeEntry.stubs(:new_from_xml).returns(val)
        FreshBooks::TimeEntry.get(@time_entry_id).should == val
      end
    end
    
    describe 'with an unsuccessful request' do
      before :each do
        @response.stubs(:success?).returns(false)
      end
      
      it 'should return nil' do
        FreshBooks::TimeEntry.get(@time_entry_id).should be_nil
      end
    end
  end
  
  describe 'getting a list' do
    before :each do
      @time_entry_id = 1
      @elements = Array.new(3) { stub('element') }
      @response = stub('response', :elements => @elements, :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    it 'should not require an argument' do
      lambda { FreshBooks::TimeEntry.list }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::TimeEntry.list('arg') }.should_not raise_error(ArgumentError)
    end
    
    it 'should issue a request for the time_entry list' do
      FreshBooks.expects(:call_api).with('time_entry.list', {}).returns(@response)
      FreshBooks::TimeEntry.list
    end
    
    it 'should pass the argument to the request' do
      arg = stub('arg')
      FreshBooks.expects(:call_api).with('time_entry.list', arg).returns(@response)
      FreshBooks::TimeEntry.list(arg)
    end
    
    describe 'with a successful request' do
      before :each do
        @response.stubs(:success?).returns(true)
      end
      
      it 'should instantiate new time_entry instances from the request' do
        @elements.each do |element|
          FreshBooks::TimeEntry.expects(:new_from_xml).with(element)
        end
        FreshBooks::TimeEntry.list
      end
      
      it 'should return the time_entry instances' do
        vals = Array.new(@elements.length) { stub('return val') }
        @elements.each_with_index do |element, i|
          FreshBooks::TimeEntry.stubs(:new_from_xml).with(element).returns(vals[i])
        end
        FreshBooks::TimeEntry.list.should == vals
      end
    end
    
    describe 'with an unsuccessful request' do
      before :each do
        @response.stubs(:success?).returns(false)
      end
      
      it 'should return nil' do
        FreshBooks::TimeEntry.list.should be_nil
      end
    end
  end
  
  it 'should have a task' do
    @time_entry.should respond_to(:task)
  end
  
  describe 'task' do
    it 'should find task based on task_id' do
      task_id = stub('task ID')
      @time_entry.stubs(:task_id).returns(task_id)
      FreshBooks::Task.expects(:get).with(task_id)
      @time_entry.task
    end
    
    it 'should return found task' do
      task = stub('task')
      task_id = stub('task ID')
      @time_entry.stubs(:task_id).returns(task_id)
      FreshBooks::Task.expects(:get).with(task_id).returns(task)
      @time_entry.task.should == task
    end
  end
  
  it 'should have a project' do
    @time_entry.should respond_to(:project)
  end
  
  describe 'project' do
    it 'should find project based on project_id' do
      project_id = stub('project ID')
      @time_entry.stubs(:project_id).returns(project_id)
      FreshBooks::Project.expects(:get).with(project_id)
      @time_entry.project
    end
    
    it 'should return found project' do
      project = stub('project')
      project_id = stub('project ID')
      @time_entry.stubs(:project_id).returns(project_id)
      FreshBooks::Project.expects(:get).with(project_id).returns(project)
      @time_entry.project.should == project
    end
  end
end
