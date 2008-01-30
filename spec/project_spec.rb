require File.dirname(__FILE__) + '/spec_helper.rb'

describe FreshBooks::Project do
  before :each do
    @project = FreshBooks::Project.new
  end
  
  describe 'attributes' do
    it 'should have a project_id' do
      @project.should respond_to(:project_id)
    end
    
    it 'should have a name' do
      @project.should respond_to(:name)
    end
    
    it 'should have a bill_method' do
      @project.should respond_to(:bill_method)
    end
    
    it 'should have a client_id' do
      @project.should respond_to(:client_id)
    end
    
    it 'should have a rate' do
      @project.should respond_to(:rate)
    end
    
    it 'should have a description' do
      @project.should respond_to(:description)
    end
  end
  
  describe 'type mappings' do
    before :each do
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
    before :each do
      @response = stub('response', :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    it 'should issue a request with the instance' do
      FreshBooks.expects(:call_api).with('project.create', 'project' => @project).returns(@response)
      @project.create
    end
    
    describe 'with a successful request' do
      before :each do
        @project_id = 5
        @response.stubs(:elements).returns([stub('pre element'), stub('element', :text => @project_id.to_s), stub('post element')])
        @response.stubs(:success?).returns(true)
      end
      
      it 'should set the ID from the response' do
        @project.expects(:project_id=).with(@project_id)
        @project.create
      end
      
      it 'should return the ID' do
        @project.create.should == @project_id
      end
    end
    
    describe 'with an unsuccessful request' do
      before :each do
        @response.stubs(:success?).returns(false)
      end
      
      it 'should not set the ID' do
        @project.expects(:project_id=).never
        @project.create
      end
      
      it 'should return nil' do
        @project.create.should be_nil
      end
    end
  end
  
  describe 'updating an instance' do
    before :each do
      @response = stub('response', :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    it 'should issue a request with the instance' do
      FreshBooks.expects(:call_api).with('project.update', 'project' => @project).returns(@response)
      @project.update
    end
    
    describe 'with a successful request' do
      before :each do
        @response.stubs(:success?).returns(true)
      end
      
      it 'should return true' do
        @project.update.should be(true)
      end
    end
    
    describe 'with an unsuccessful request' do
      before :each do
        @response.stubs(:success?).returns(false)
      end
      
      it 'should return false' do
        @project.update.should be(false)
      end
    end
  end
  
  describe 'deleting an instance' do
    before :each do
      @project_id = '5'
      @response = stub('response', :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    describe 'from the class' do
      it 'should require an argument' do
        lambda { FreshBooks::Project.delete }.should raise_error(ArgumentError)
      end
      
      it 'should accept an argument' do
        lambda { FreshBooks::Project.delete('arg') }.should_not raise_error(ArgumentError)
      end
      
      it 'should issue a request with the supplied ID' do
        FreshBooks.expects(:call_api).with('project.delete', 'project_id' => @project_id).returns(@response)
        FreshBooks::Project.delete(@project_id)
      end
      
      describe 'with a successful request' do
        before :each do
          @response.stubs(:success?).returns(true)
        end
        
        it 'should return true' do
          FreshBooks::Project.delete(@project_id).should be(true)
        end
      end
      
      describe 'with an unsuccessful request' do
        before :each do
          @response.stubs(:success?).returns(false)
        end
        
        it 'should return false' do
          FreshBooks::Project.delete(@project_id).should be(false)
        end
      end
    end
    
    describe 'from the instance' do
      before :each do
        @project.stubs(:project_id).returns(@project_id)
        FreshBooks::Project.stubs(:delete)
      end
      
      it 'should delegate to the class' do
        FreshBooks::Project.expects(:delete)
        @project.delete
      end
      
      it 'should pass its ID to the class method' do
        FreshBooks::Project.expects(:delete).with(@project_id)
        @project.delete
      end
      
      it 'should return the result from the class method' do
        val = stub('return val')
        FreshBooks::Project.stubs(:delete).returns(val)
        @project.delete.should == val
      end
    end
  end
  
  describe 'getting an instance' do
    before :each do
      @project_id = 1
      @element = stub('element')
      @response = stub('response', :elements => [stub('pre element'), @element, stub('post element')], :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    it 'should require an argument' do
      lambda { FreshBooks::Project.get }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::Project.get(@project_id) }.should_not raise_error(ArgumentError)
    end
    
    it 'should issue a request for the supplied ID' do
      FreshBooks.expects(:call_api).with('project.get', 'project_id' => @project_id).returns(@response)
      FreshBooks::Project.get(@project_id)
    end
    
    describe 'with a successful request' do
      before :each do
        @response.stubs(:success?).returns(true)
      end
      
      it 'should instantiate a new project instance from the request' do
        FreshBooks::Project.expects(:new_from_xml).with(@element)
        FreshBooks::Project.get(@project_id)
      end
      
      it 'should return the project instance' do
        val = stub('return val')
        FreshBooks::Project.stubs(:new_from_xml).returns(val)
        FreshBooks::Project.get(@project_id).should == val
      end
    end
    
    describe 'with an unsuccessful request' do
      before :each do
        @response.stubs(:success?).returns(false)
      end
      
      it 'should return nil' do
        FreshBooks::Project.get(@project_id).should be_nil
      end
    end
  end
  
  describe 'getting a list' do
    before :each do
      @project_id = 1
      @elements = Array.new(3) { stub('element') }
      @response = stub('response', :elements => @elements, :success? => nil)
      FreshBooks.stubs(:call_api).returns(@response)
    end
    
    it 'should not require an argument' do
      lambda { FreshBooks::Project.list }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::Project.list('arg') }.should_not raise_error(ArgumentError)
    end
    
    it 'should issue a request for the time_entry list' do
      FreshBooks.expects(:call_api).with('project.list', {}).returns(@response)
      FreshBooks::Project.list
    end
    
    it 'should pass the argument to the request' do
      arg = stub('arg')
      FreshBooks.expects(:call_api).with('project.list', arg).returns(@response)
      FreshBooks::Project.list(arg)
    end
    
    describe 'with a successful request' do
      before :each do
        @response.stubs(:success?).returns(true)
      end
      
      it 'should instantiate new project instances from the request' do
        @elements.each do |element|
          FreshBooks::Project.expects(:new_from_xml).with(element)
        end
        FreshBooks::Project.list
      end
      
      it 'should return the project instances' do
        vals = Array.new(@elements.length) { stub('return val') }
        @elements.each_with_index do |element, i|
          FreshBooks::Project.stubs(:new_from_xml).with(element).returns(vals[i])
        end
        FreshBooks::Project.list.should == vals
      end
    end
    
    describe 'with an unsuccessful request' do
      before :each do
        @response.stubs(:success?).returns(false)
      end
      
      it 'should return nil' do
        FreshBooks::Project.list.should be_nil
      end
    end
  end
  
  describe 'getting by name' do
    before :each do
      @name = 'projname'
      FreshBooks::Project.stubs(:list).returns([])
    end
    
    it 'should require an argument' do
      lambda { FreshBooks::Project.find_by_name }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { FreshBooks::Project.find_by_name(@name) }.should_not raise_error(ArgumentError)
    end
    
    it 'should return the project with a matching name' do
      projects = Array.new(3) { |i| stub('project', :name => "project #{i}" ) }
      projects[1,0] = expected = stub('project', :name => @name)
      FreshBooks::Project.stubs(:list).returns(projects)
      FreshBooks::Project.find_by_name(@name).should == expected
    end
    
    it 'should return the first project found whose name matches' do
      projects = Array.new(3) { |i| stub('project', :name => "project #{i}" ) }
      projects[1,0] = expected = stub('project', :name => @name)
      projects[3,0] = stub('project', :name => @name)
      FreshBooks::Project.stubs(:list).returns(projects)
      FreshBooks::Project.find_by_name(@name).should == expected
    end
    
    it 'should return nil if no project with matching name found' do
      projects = Array.new(3) { |i| stub('project', :name => "project #{i}" ) }
      FreshBooks::Project.stubs(:list).returns(projects)
      FreshBooks::Project.find_by_name(@name).should be_nil
    end
  end
  
  it 'should have a client' do
    @project.should respond_to(:client)
  end
  
  describe 'client' do
    it 'should find client based on client_id' do
      client_id = stub('client ID')
      @project.stubs(:client_id).returns(client_id)
      FreshBooks::Client.expects(:get).with(client_id)
      @project.client
    end
    
    it 'should return found client' do
      client = stub('client')
      client_id = stub('client ID')
      @project.stubs(:client_id).returns(client_id)
      FreshBooks::Client.stubs(:get).with(client_id).returns(client)
      @project.client.should == client
    end
  end
  
  it 'should have tasks' do
    @project.should respond_to(:tasks)
  end
  
  describe 'tasks' do
    it 'should list tasks based on project ID' do
      project_id = stub('project ID')
      @project.stubs(:project_id).returns(project_id)
      FreshBooks::Task.expects(:list).with('project_id' => project_id)
      @project.tasks
    end
    
    it 'should return found tasks' do
      tasks = stub('tasks')
      project_id = stub('project ID')
      @project.stubs(:project_id).returns(project_id)
      FreshBooks::Task.stubs(:list).with('project_id' => project_id).returns(tasks)
      @project.tasks.should == tasks
    end
  end
  
  it 'should have time entries' do
    @project.should respond_to(:time_entries)
  end
  
  describe 'time entries' do
    it 'should list time entries based on project ID' do
      project_id = stub('project ID')
      @project.stubs(:project_id).returns(project_id)
      FreshBooks::TimeEntry.expects(:list).with('project_id' => project_id)
      @project.time_entries
    end
    
    it 'should return found time entries' do
      time_entries = stub('time entries')
      project_id = stub('project ID')
      @project.stubs(:project_id).returns(project_id)
      FreshBooks::TimeEntry.stubs(:list).with('project_id' => project_id).returns(time_entries)
      @project.time_entries.should == time_entries
    end
  end
end
