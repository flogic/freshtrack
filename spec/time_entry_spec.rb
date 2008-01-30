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
    
    it 'should issue a request for the time_entry list' do
      FreshBooks.expects(:call_api).with('time_entry.list').returns(@response)
      FreshBooks::TimeEntry.list
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