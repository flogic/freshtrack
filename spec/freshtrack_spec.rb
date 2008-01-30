require File.dirname(__FILE__) + '/spec_helper.rb'

describe Freshtrack do
  describe 'loading configuration' do
    before :each do
      File.stubs(:read).returns('')
    end
    
    it 'should load the contents of the .freshtrack.yml file' do
      File.stubs(:expand_path).with('~/.freshtrack.yml').returns('~/.freshtrack.yml')
      File.expects(:read).with('~/.freshtrack.yml').returns('')
      Freshtrack.load_config
    end
    
    it 'should turn the file contents into data' do
      file_contents = stub('lorem ipsum')
      File.stubs(:read).returns(file_contents)
      YAML.expects(:load).with(file_contents)
      Freshtrack.load_config
    end
    
    it 'should store the configuration data' do
      config = stub('config data')
      YAML.stubs(:load).returns(config)
      Freshtrack.load_config
      Freshtrack.config.should == config
    end
  end
    
  describe 'getting configuration data' do
    before :each do
      @config = {}
      Freshtrack.stubs(:config).returns(@config)
    end
    
    it 'should provide easy access to the company name' do
      @config['company'] = company = stub('company name')
      Freshtrack.company.should == company
    end
    
    it 'should provide easy access to the token' do
      @config['token'] = token = stub('token')
      Freshtrack.token.should == token
    end
    
    it 'should provide easy access to the project/task mapping' do
      @config['project_task_mapping'] = project_task_mapping = stub('project/task mapping')
      Freshtrack.project_task_mapping.should == project_task_mapping
    end
  end
  
  describe 'initialization' do
    before :each do
      @company = 'zee_company_boss'
      @token = 'token goes here'
      Freshtrack.stubs(:load_config)
      Freshtrack.stubs(:config).returns({ 'company' => @company, 'token' => @token })
    end
    
    it 'should load the configuration' do
      Freshtrack.expects(:load_config)
      Freshtrack.init
    end
    
    it 'should use the config data to set up FreshBooks' do
      FreshBooks.expects(:setup).with("#{@company}.freshbooks.com", @token)
      Freshtrack.init
    end
  end
  
  describe 'getting project data' do
    before :each do
      @project_name = :proj
      @project_task_mapping = { @project_name => { :project => 'fb proj', :task => 'fb task' } }
      Freshtrack.stubs(:project_task_mapping).returns(@project_task_mapping)
      @project = stub('project')
      @task = stub('task')
      FreshBooks::Project.stubs(:find_by_name).returns(@project)
      FreshBooks::Task.stubs(:find_by_name).returns(@task)
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.get_project_data }.should raise_error(ArgumentError)
    end
    it 'should accept an argument' do
      lambda { Freshtrack.get_project_data(@project_name) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require the argument to be a valid project identifier' do
      @project_task_mapping.delete(@project_name)
      lambda { Freshtrack.get_project_data(@project_name) }.should raise_error
    end
    
    it 'should accept an argument that is a valid project identifier' do
      lambda { Freshtrack.get_project_data(@project_name) }.should_not raise_error
    end
    
    it 'should get the indicated FreshBooks project' do
      FreshBooks::Project.expects(:find_by_name).with(@project_task_mapping[@project_name][:project]).returns(@project)
      Freshtrack.get_project_data(@project_name)
    end
    
    it 'should abort if no FreshBooks project found' do
      FreshBooks::Project.stubs(:find_by_name).returns(nil)
      lambda { Freshtrack.get_project_data(@project_name) }.should raise_error
    end
    
    it 'should provide easy access to the project' do
      FreshBooks::Project.stubs(:find_by_name).returns(@project)
      Freshtrack.get_project_data(@project_name)
      Freshtrack.project.should == @project
    end
    
    it 'should get the indicated FreshBooks task' do
      FreshBooks::Task.expects(:find_by_name).with(@project_task_mapping[@project_name][:task]).returns(@task)
      Freshtrack.get_project_data(@project_name)
    end
    
    it 'should abort if no FreshBooks task found' do
      FreshBooks::Task.stubs(:find_by_name).returns(nil)
      lambda { Freshtrack.get_project_data(@project_name) }.should raise_error
    end
    
    it 'should provide easy access to the task' do
      FreshBooks::Task.stubs(:find_by_name).returns(@task)
      Freshtrack.get_project_data(@project_name)
      Freshtrack.task.should == @task
    end
  end
end
