require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe FreshBooks::Project do
  before do
    @project = FreshBooks::Project.new
  end
  
  describe 'attributes' do
    it 'should have a project_id' do
      @project.should.respond_to(:project_id)
    end
    
    it 'should have a name' do
      @project.should.respond_to(:name)
    end
    
    it 'should have a bill_method' do
      @project.should.respond_to(:bill_method)
    end
    
    it 'should have a client_id' do
      @project.should.respond_to(:client_id)
    end
    
    it 'should have a rate' do
      @project.should.respond_to(:rate)
    end
    
    it 'should have a description' do
      @project.should.respond_to(:description)
    end
  end
  
  describe 'type mappings' do
    before do
      @mapping = FreshBooks::Project::TYPE_MAPPINGS
    end
    
    it 'should map project_id to Fixnum' do
      @mapping['project_id'].should == Fixnum
    end
    
    it 'should map client_id to Fixnum' do
      @mapping['client_id'].should == Fixnum
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
      FreshBooks.should.receive(:call_api).with('project.create', 'project' => @project).and_return(@response)
      @project.create
    end
    
    describe 'with a successful request' do
      before do
        @project_id = 5
        @response.stub!(:elements).and_return([mock('pre element'), mock('element', :text => @project_id.to_s), mock('post element')])
        @response.stub!(:success?).and_return(true)
      end
      
      it 'should set the ID from the response' do
        @project.should.receive(:project_id=).with(@project_id)
        @project.create
      end
      
      it 'should return the ID' do
        @project.create.should == @project_id
      end
    end
    
    describe 'with an unsuccessful request' do
      before do
        @response.stub!(:success?).and_return(false)
      end
      
      it 'should not set the ID' do
        @project.should.receive(:project_id=).never
        @project.create
      end
      
      it 'should return nil' do
        @project.create.should.be.nil
      end
    end
  end
  
  describe 'updating an instance' do
    before do
      @response = mock('response', :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    it 'should issue a request with the instance' do
      FreshBooks.should.receive(:call_api).with('project.update', 'project' => @project).and_return(@response)
      @project.update
    end
    
    describe 'with a successful request' do
      before do
        @response.stub!(:success?).and_return(true)
      end
      
      it 'should return true' do
        @project.update.should == true
      end
    end
    
    describe 'with an unsuccessful request' do
      before do
        @response.stub!(:success?).and_return(false)
      end
      
      it 'should return false' do
        @project.update.should == false
      end
    end
  end
  
  describe 'deleting an instance' do
    before do
      @project_id = '5'
      @response = mock('response', :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    describe 'from the class' do
      it 'should require an argument' do
        lambda { FreshBooks::Project.delete }.should.raise(ArgumentError)
      end
      
      it 'should accept an argument' do
        lambda { FreshBooks::Project.delete('arg') }.should.not.raise(ArgumentError)
      end
      
      it 'should issue a request with the supplied ID' do
        FreshBooks.should.receive(:call_api).with('project.delete', 'project_id' => @project_id).and_return(@response)
        FreshBooks::Project.delete(@project_id)
      end
      
      describe 'with a successful request' do
        before do
          @response.stub!(:success?).and_return(true)
        end
        
        it 'should return true' do
          FreshBooks::Project.delete(@project_id).should == true
        end
      end
      
      describe 'with an unsuccessful request' do
        before do
          @response.stub!(:success?).and_return(false)
        end
        
        it 'should return false' do
          FreshBooks::Project.delete(@project_id).should == false
        end
      end
    end
    
    describe 'from the instance' do
      before do
        @project.stub!(:project_id).and_return(@project_id)
        FreshBooks::Project.stub!(:delete)
      end
      
      it 'should delegate to the class' do
        FreshBooks::Project.should.receive(:delete)
        @project.delete
      end
      
      it 'should pass its ID to the class method' do
        FreshBooks::Project.should.receive(:delete).with(@project_id)
        @project.delete
      end
      
      it 'should return the result from the class method' do
        val = mock('return val')
        FreshBooks::Project.stub!(:delete).and_return(val)
        @project.delete.should == val
      end
    end
  end
  
  describe 'getting an instance' do
    before do
      @project_id = 1
      @element = mock('element')
      @response = mock('response', :elements => [mock('pre element'), @element, mock('post element')], :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    it 'should require an argument' do
      lambda { FreshBooks::Project.get }.should.raise(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::Project.get(@project_id) }.should.not.raise(ArgumentError)
    end
    
    it 'should issue a request for the supplied ID' do
      FreshBooks.should.receive(:call_api).with('project.get', 'project_id' => @project_id).and_return(@response)
      FreshBooks::Project.get(@project_id)
    end
    
    describe 'with a successful request' do
      before do
        @response.stub!(:success?).and_return(true)
      end
      
      it 'should instantiate a new project instance from the request' do
        FreshBooks::Project.should.receive(:new_from_xml).with(@element)
        FreshBooks::Project.get(@project_id)
      end
      
      it 'should return the project instance' do
        val = mock('return val')
        FreshBooks::Project.stub!(:new_from_xml).and_return(val)
        FreshBooks::Project.get(@project_id).should == val
      end
    end
    
    describe 'with an unsuccessful request' do
      before do
        @response.stub!(:success?).and_return(false)
      end
      
      it 'should return nil' do
        FreshBooks::Project.get(@project_id).should.be.nil
      end
    end
  end
  
  describe 'getting a list' do
    before do
      @project_id = 1
      @elements = Array.new(3) { mock('list element') }
      @response = mock('response', :elements => [mock('pre element'), mock('element', :elements => @elements), mock('post element')], :success? => nil)
      FreshBooks.stub!(:call_api).and_return(@response)
    end
    
    it 'should not require an argument' do
      lambda { FreshBooks::Project.list }.should.not.raise(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::Project.list('arg') }.should.not.raise(ArgumentError)
    end
    
    it 'should issue a request for the time_entry list' do
      FreshBooks.should.receive(:call_api).with('project.list', {}).and_return(@response)
      FreshBooks::Project.list
    end
    
    it 'should pass the argument to the request' do
      arg = mock('arg')
      FreshBooks.should.receive(:call_api).with('project.list', arg).and_return(@response)
      FreshBooks::Project.list(arg)
    end
    
    describe 'with a successful request' do
      before do
        @response.stub!(:success?).and_return(true)
      end
      
      it 'should instantiate new project instances from the request' do
        @elements.each do |element|
          FreshBooks::Project.should.receive(:new_from_xml).with(element)
        end
        FreshBooks::Project.list
      end
      
      it 'should return the project instances' do
        vals = Array.new(@elements.length) { mock('return val') }
        @elements.each_with_index do |element, i|
          FreshBooks::Project.stub!(:new_from_xml).with(element).and_return(vals[i])
        end
        FreshBooks::Project.list.should == vals
      end
    end
    
    describe 'with an unsuccessful request' do
      before do
        @response.stub!(:success?).and_return(false)
      end
      
      it 'should return nil' do
        FreshBooks::Project.list.should.be.nil
      end
    end
  end
  
  describe 'getting by name' do
    before do
      @name = 'projname'
      FreshBooks::Project.stub!(:list).and_return([])
    end
    
    it 'should require an argument' do
      lambda { FreshBooks::Project.find_by_name }.should.raise(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::Project.find_by_name(@name) }.should.not.raise(ArgumentError)
    end
    
    it 'should return the project with a matching name' do
      projects = Array.new(3) { |i| mock('project', :name => "project #{i}" ) }
      projects[1,0] = expected = mock('project', :name => @name)
      FreshBooks::Project.stub!(:list).and_return(projects)
      FreshBooks::Project.find_by_name(@name).should == expected
    end
    
    it 'should return the first project found whose name matches' do
      projects = Array.new(3) { |i| mock('project', :name => "project #{i}" ) }
      projects[1,0] = expected = mock('project', :name => @name)
      projects[3,0] = mock('project', :name => @name)
      FreshBooks::Project.stub!(:list).and_return(projects)
      FreshBooks::Project.find_by_name(@name).should == expected
    end
    
    it 'should return nil if no project with matching name found' do
      projects = Array.new(3) { |i| mock('project', :name => "project #{i}" ) }
      FreshBooks::Project.stub!(:list).and_return(projects)
      FreshBooks::Project.find_by_name(@name).should.be.nil
    end
  end
  
  it 'should have a client' do
    @project.should.respond_to(:client)
  end
  
  describe 'client' do
    it 'should find client based on client_id' do
      client_id = mock('client ID')
      @project.stub!(:client_id).and_return(client_id)
      FreshBooks::Client.should.receive(:get).with(client_id)
      @project.client
    end
    
    it 'should return found client' do
      client = mock('client')
      client_id = mock('client ID')
      @project.stub!(:client_id).and_return(client_id)
      FreshBooks::Client.stub!(:get).with(client_id).and_return(client)
      @project.client.should == client
    end
  end
  
  it 'should have tasks' do
    @project.should.respond_to(:tasks)
  end
  
  describe 'tasks' do
    it 'should list tasks based on project ID' do
      project_id = mock('project ID')
      @project.stub!(:project_id).and_return(project_id)
      FreshBooks::Task.should.receive(:list).with('project_id' => project_id)
      @project.tasks
    end
    
    it 'should return found tasks' do
      tasks = mock('tasks')
      project_id = mock('project ID')
      @project.stub!(:project_id).and_return(project_id)
      FreshBooks::Task.stub!(:list).with('project_id' => project_id).and_return(tasks)
      @project.tasks.should == tasks
    end
  end
  
  it 'should have time entries' do
    @project.should.respond_to(:time_entries)
  end
  
  describe 'time entries' do
    it 'should list time entries based on project ID' do
      project_id = mock('project ID')
      @project.stub!(:project_id).and_return(project_id)
      FreshBooks::TimeEntry.should.receive(:list).with('project_id' => project_id)
      @project.time_entries
    end
    
    it 'should return found time entries' do
      time_entries = mock('time entries')
      project_id = mock('project ID')
      @project.stub!(:project_id).and_return(project_id)
      FreshBooks::TimeEntry.stub!(:list).with('project_id' => project_id).and_return(time_entries)
      @project.time_entries.should == time_entries
    end
  end
end
