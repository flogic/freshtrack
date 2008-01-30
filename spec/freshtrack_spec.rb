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
  
  describe 'getting time data' do
    before :each do
      @project_name = :proj
      @time_data = stub('time data')
      IO.stubs(:read).returns(@time_data)
      Freshtrack.stubs(:convert_time_data)
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.get_time_data }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { Freshtrack.get_time_data(@project_name) }.should_not raise_error(ArgumentError)
    end
    
    it 'should get the time data (from punch)' do
      IO.expects(:read).with(regexp_matches(/^\| punch list\b/))
      Freshtrack.get_time_data(@project_name)
    end
    
    it 'should pass the supplied project when getting the time data' do
      IO.expects(:read).with(regexp_matches(/\b#{@project_name}$/))
      Freshtrack.get_time_data(@project_name)
    end
    
    it 'should convert the time data' do
      Freshtrack.expects(:convert_time_data).with(@time_data)
      Freshtrack.get_time_data(@project_name)
    end
    
    it 'should return the converted data' do
      converted = stub('converted time data')
      Freshtrack.stubs(:convert_time_data).returns(converted)
      Freshtrack.get_time_data(@project_name).should == converted
    end    
  end
  
  describe 'converting time data' do
    before :each do
      @time_data = stub('time data')
      YAML.stubs(:load)
      Freshtrack.stubs(:condense_time_data)
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.convert_time_data }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { Freshtrack.convert_time_data(@time_data) }.should_not raise_error(ArgumentError)
    end
    
    it 'should convert the time data from YAML' do
      YAML.expects(:load).with(@time_data)
      Freshtrack.convert_time_data(@time_data)
    end
    
    it 'should condense the raw data' do
      raw = stub('raw time data')
      YAML.stubs(:load).returns(raw)
      Freshtrack.expects(:condense_time_data).with(raw)
      Freshtrack.convert_time_data(@project_name)
    end
    
    it 'should return the condensed data' do
      condensed = stub('condensed time data')
      Freshtrack.stubs(:condense_time_data).returns(condensed)
      Freshtrack.convert_time_data(@time_data).should == condensed
    end
  end
  
  describe 'condensing time data' do
    before :each do
      @time_data = stub('time data')
      Freshtrack.stubs(:times_to_dates)
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.condense_time_data }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { Freshtrack.condense_time_data(@time_data) }.should_not raise_error(ArgumentError)
    end
    
    it 'should convert times to dates and hour differences' do
      Freshtrack.expects(:times_to_dates).with(@time_data)
      Freshtrack.condense_time_data(@time_data)
    end
  end
  
  describe 'converting times to dates and hour differences' do
    before :each do
      @time_data = []
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.times_to_dates }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { Freshtrack.times_to_dates(@time_data) }.should_not raise_error(ArgumentError)
    end
    
    it 'should return an array' do
      Freshtrack.times_to_dates(@time_data).should be_kind_of(Array)
    end
    
    it 'should replace the in/out time data with a single date' do
      @time_data.push({ 'in' => Time.local(2008, 1, 25, 6,  25, 0), 'out' => Time.local(2008, 1, 25, 7,  25, 0) })
      result = Freshtrack.times_to_dates(@time_data)
      result = result.first
      
      result.should     have_key('date')
      result.should_not have_key('in')
      result.should_not have_key('out')
    end
    
    it 'should make the date appopriate to the time' do
      @time_data.push({ 'in' => Time.local(2008, 1, 25, 6,  25, 0), 'out' => Time.local(2008, 1, 25, 7,  25, 0) })
      result = Freshtrack.times_to_dates(@time_data)
      result = result.first
      result['date'].should == Date.civil(2008, 1, 25)
    end
    
    it 'should use the in time date' do
      @time_data.push({ 'in' => Time.local(2008, 1, 25, 6,  25, 0), 'out' => Time.local(2008, 1, 26, 7,  25, 0) })
      result = Freshtrack.times_to_dates(@time_data)
      result = result.first
      result['date'].should == Date.civil(2008, 1, 25)
    end
    
    it 'should add hour data' do
      @time_data.push({ 'in' => Time.local(2008, 1, 25, 6,  25, 0), 'out' => Time.local(2008, 1, 25, 7,  25, 0) })
      result = Freshtrack.times_to_dates(@time_data)
      result = result.first
      result.should have_key('hours')
    end
    
    it 'should make the hour data appropriate to the in/out difference' do
      @time_data.push({ 'in' => Time.local(2008, 1, 25, 6,  25, 0), 'out' => Time.local(2008, 1, 25, 7,  55, 0) })
      result = Freshtrack.times_to_dates(@time_data)
      result = result.first
      result['hours'].should == 1.5
    end
  end
  
  describe 'getting data' do
    before :each do
      @project_name = :proj
      Freshtrack.stubs(:get_project_data)
      Freshtrack.stubs(:get_time_data)
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.get_data }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { Freshtrack.get_data(@project_name) }.should_not raise_error(ArgumentError)
    end
    
    it 'should get project data for supplied project' do
      Freshtrack.expects(:get_project_data).with(@project_name)
      Freshtrack.get_data(@project_name)
    end
    
    it 'should get time data for supplied project' do
      Freshtrack.expects(:get_time_data).with(@project_name)
      Freshtrack.get_data(@project_name)
    end
  end
end
