require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe FreshBooks::TimeEntry do
  before do
    @time_entry = FreshBooks::TimeEntry.new
  end
  
  describe 'attributes' do
    it 'should have a time_entry_id' do
      @time_entry.should.respond_to(:time_entry_id)
    end
    
    it 'should have a project_id' do
      @time_entry.should.respond_to(:project_id)
    end
    
    it 'should have a task_id' do
      @time_entry.should.respond_to(:task_id)
    end
    
    it 'should have hours' do
      @time_entry.should.respond_to(:hours)
    end
    
    it 'should have a date' do
      @time_entry.should.respond_to(:date)
    end
    
    it 'should have notes' do
      @time_entry.should.respond_to(:notes)
    end

    it 'should have billed' do
      @time_entry.should.respond_to(:billed)
    end
  end
  
  describe 'type mappings' do
    before do
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

    it 'should map billed to boolean' do
      @mapping['billed'].should == :boolean
    end
  end
  
  describe 'creating an instance' do
    before do
      @response = mock('response', :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    it 'should issue a request with the instance' do
      FreshBooks.should.receive(:call_api).with('time_entry.create', 'time_entry' => @time_entry).and_return(@response)
      @time_entry.create
    end
    
    describe 'with a successful request' do
      before do
        @time_entry_id = 5
        @response.stub!(:elements).and_return([mock('pre element'), mock('element', :text => @time_entry_id.to_s), mock('post element')])
        @response.stub!(:success?).and_return(true)
      end
      
      it 'should set the ID from the response' do
        @time_entry.should.receive(:time_entry_id=).with(@time_entry_id)
        @time_entry.create
      end
      
      it 'should return the ID' do
        @time_entry.create.should == @time_entry_id
      end
    end
    
    describe 'with an unsuccessful request' do
      before do
        @response.stub!(:success?).and_return(false)
      end
      
      it 'should not set the ID' do
        @time_entry.should.receive(:time_entry_id=).never
        @time_entry.create
      end
      
      it 'should return nil' do
        @time_entry.create.should.be.nil
      end
    end
  end
  
  describe 'updating an instance' do
    before do
      @response = mock('response', :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    it 'should issue a request with the instance' do
      FreshBooks.should.receive(:call_api).with('time_entry.update', 'time_entry' => @time_entry).and_return(@response)
      @time_entry.update
    end
    
    describe 'with a successful request' do
      before do
        @response.stub!(:success?).and_return(true)
      end
      
      it 'should return true' do
        @time_entry.update.should == true
      end
    end
    
    describe 'with an unsuccessful request' do
      before do
        @response.stub!(:success?).and_return(false)
      end
      
      it 'should return false' do
        @time_entry.update.should == false
      end
    end
  end
  
  describe 'deleting an instance' do
    before do
      @time_entry_id = '5'
      @response = mock('response', :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    describe 'from the class' do
      it 'should require an argument' do
        lambda { FreshBooks::TimeEntry.delete }.should.raise(ArgumentError)
      end
      
      it 'should accept an argument' do
        lambda { FreshBooks::TimeEntry.delete('arg') }.should.not.raise(ArgumentError)
      end
      
      it 'should issue a request with the supplied ID' do
        FreshBooks.should.receive(:call_api).with('time_entry.delete', 'time_entry_id' => @time_entry_id).and_return(@response)
        FreshBooks::TimeEntry.delete(@time_entry_id)
      end
      
      describe 'with a successful request' do
        before do
          @response.stub!(:success?).and_return(true)
        end
        
        it 'should return true' do
          FreshBooks::TimeEntry.delete(@time_entry_id).should == true
        end
      end
      
      describe 'with an unsuccessful request' do
        before do
          @response.stub!(:success?).and_return(false)
        end
        
        it 'should return false' do
          FreshBooks::TimeEntry.delete(@time_entry_id).should == false
        end
      end
    end
    
    describe 'from the instance' do
      before do
        @time_entry.stub!(:time_entry_id).and_return(@time_entry_id)
        FreshBooks::TimeEntry.stub!(:delete)
      end
      
      it 'should delegate to the class' do
        FreshBooks::TimeEntry.should.receive(:delete)
        @time_entry.delete
      end
      
      it 'should pass its ID to the class method' do
        FreshBooks::TimeEntry.should.receive(:delete).with(@time_entry_id)
        @time_entry.delete
      end
      
      it 'should return the result from the class method' do
        val = mock('return val')
        FreshBooks::TimeEntry.stub!(:delete).and_return(val)
        @time_entry.delete.should == val
      end
    end
  end
  
  describe 'getting an instance' do
    before do
      @time_entry_id = 1
      @element = mock('element')
      @response = mock('response', :elements => [mock('pre element'), @element, mock('post element')], :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    it 'should require an argument' do
      lambda { FreshBooks::TimeEntry.get }.should.raise(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::TimeEntry.get(@time_entry_id) }.should.not.raise(ArgumentError)
    end
    
    it 'should issue a request for the supplied ID' do
      FreshBooks.should.receive(:call_api).with('time_entry.get', 'time_entry_id' => @time_entry_id).and_return(@response)
      FreshBooks::TimeEntry.get(@time_entry_id)
    end
    
    describe 'with a successful request' do
      before do
        @response.stub!(:success?).and_return(true)
      end
      
      it 'should instantiate a new time_entry instance from the request' do
        FreshBooks::TimeEntry.should.receive(:new_from_xml).with(@element)
        FreshBooks::TimeEntry.get(@time_entry_id)
      end
      
      it 'should return the time_entry instance' do
        val = mock('return val')
        FreshBooks::TimeEntry.stub!(:new_from_xml).and_return(val)
        FreshBooks::TimeEntry.get(@time_entry_id).should == val
      end
    end
    
    describe 'with an unsuccessful request' do
      before do
        @response.stub!(:success?).and_return(false)
      end
      
      it 'should return nil' do
        FreshBooks::TimeEntry.get(@time_entry_id).should.be.nil
      end
    end
  end
  
  describe 'getting a list' do
    before do
      @time_entry_id = 1
      @elements = Array.new(3) { mock('list element') }
      @response = mock('response', :elements => [mock('pre element'), mock('element', :elements => @elements), mock('post element')], :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    it 'should not require an argument' do
      lambda { FreshBooks::TimeEntry.list }.should.not.raise(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::TimeEntry.list('arg') }.should.not.raise(ArgumentError)
    end
    
    it 'should issue a request for the time_entry list' do
      FreshBooks.should.receive(:call_api).with('time_entry.list', {}).and_return(@response)
      FreshBooks::TimeEntry.list
    end
    
    it 'should pass the argument to the request' do
      arg = mock('arg')
      FreshBooks.should.receive(:call_api).with('time_entry.list', arg).and_return(@response)
      FreshBooks::TimeEntry.list(arg)
    end
    
    describe 'with a successful request' do
      before do
        @response.stub!(:success?).and_return(true)
      end
      
      it 'should instantiate new time_entry instances from the request' do
        @elements.each do |element|
          FreshBooks::TimeEntry.should.receive(:new_from_xml).with(element)
        end
        FreshBooks::TimeEntry.list
      end
      
      it 'should return the time_entry instances' do
        vals = Array.new(@elements.length) { mock('return val') }
        @elements.each_with_index do |element, i|
          FreshBooks::TimeEntry.stub!(:new_from_xml).with(element).and_return(vals[i])
        end
        FreshBooks::TimeEntry.list.should == vals
      end
    end
    
    describe 'with an unsuccessful request' do
      before do
        @response.stub!(:success?).and_return(false)
      end
      
      it 'should return nil' do
        FreshBooks::TimeEntry.list.should.be.nil
      end
    end
  end
  
  it 'should have a task' do
    @time_entry.should.respond_to(:task)
  end
  
  describe 'task' do
    it 'should find task based on task_id' do
      task_id = mock('task ID')
      @time_entry.stub!(:task_id).and_return(task_id)
      FreshBooks::Task.should.receive(:get).with(task_id)
      @time_entry.task
    end
    
    it 'should return found task' do
      task = mock('task')
      task_id = mock('task ID')
      @time_entry.stub!(:task_id).and_return(task_id)
      FreshBooks::Task.should.receive(:get).with(task_id).and_return(task)
      @time_entry.task.should == task
    end
  end
  
  it 'should have a project' do
    @time_entry.should.respond_to(:project)
  end
  
  describe 'project' do
    it 'should find project based on project_id' do
      project_id = mock('project ID')
      @time_entry.stub!(:project_id).and_return(project_id)
      FreshBooks::Project.should.receive(:get).with(project_id)
      @time_entry.project
    end
    
    it 'should return found project' do
      project = mock('project')
      project_id = mock('project ID')
      @time_entry.stub!(:project_id).and_return(project_id)
      FreshBooks::Project.should.receive(:get).with(project_id).and_return(project)
      @time_entry.project.should == project
    end
  end
end
