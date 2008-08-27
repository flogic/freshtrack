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
      Punch.stubs(:load)
      Punch.stubs(:list).returns(@time_data)
      Freshtrack.stubs(:condense_time_data)
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.get_time_data }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { Freshtrack.get_time_data(@project_name) }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept an option string' do
      lambda { Freshtrack.get_time_data(@project_name, 'option string') }.should_not raise_error(ArgumentError)
    end
    
    it 'should have punch load the time data' do
      Punch.expects(:load)
      Freshtrack.get_time_data(@project_name)
    end
    
    it 'should get the time data from punch' do
      Punch.expects(:list)
      Freshtrack.get_time_data(@project_name)
    end
    
    it 'should pass the supplied project when getting the time data' do
      Punch.expects(:list).with(@project_name)
      Freshtrack.get_time_data(@project_name)
    end
    
    it 'should pass the supplied options on when getting the time data' do
      pending 'options'
      options = 'options go here'
      IO.expects(:read).with(regexp_matches(/\b#{@project_name} #{options}\b/))
      Freshtrack.get_time_data(@project_name, options)
    end
    
    it 'should pass no options by default' do
      pending 'options'
      IO.expects(:read).with(regexp_matches(/\b#{@project_name} $/))
      Freshtrack.get_time_data(@project_name)
    end
    
    it 'should condense the time data' do
      Freshtrack.expects(:condense_time_data).with(@time_data)
      Freshtrack.get_time_data(@project_name)
    end
    
    it 'should return the condensed data' do
      condensed = stub('condensed time data')
      Freshtrack.stubs(:condense_time_data).returns(condensed)
      Freshtrack.get_time_data(@project_name).should == condensed
    end
  end
  
  describe 'condensing time data' do
    before :each do
      @time_data = stub('time data')
      Freshtrack.stubs(:times_to_dates)
      Freshtrack.stubs(:group_date_data)
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
    
    it 'should group date and hour differences' do
      date_hour_data = stub('date/hour data')
      Freshtrack.stubs(:times_to_dates).returns(date_hour_data)
      Freshtrack.expects(:group_date_data).with(date_hour_data)
      Freshtrack.condense_time_data(@time_data)
    end
    
    it 'should return the grouped date/hour data' do
      grouped_dates = stub('grouped date/hour data')
      Freshtrack.stubs(:group_date_data).returns(grouped_dates)
      Freshtrack.condense_time_data(@time_data).should == grouped_dates
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
  
  describe 'grouping date data' do
    before :each do
      @date_data = []
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.group_date_data }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { Freshtrack.group_date_data(@date_data) }.should_not raise_error(ArgumentError)
    end
    
    it 'should return an array' do
      Freshtrack.group_date_data(@date_data).should be_kind_of(Array)
    end
    
    it 'should group the data by date' do
      today = Date.today
      @date_data.push({ 'date' => today,     'hours' => 0, 'log' => [] })
      @date_data.push({ 'date' => today,     'hours' => 0, 'log' => [] })
      @date_data.push({ 'date' => today + 1, 'hours' => 0, 'log' => [] })
      Freshtrack.group_date_data(@date_data).collect { |x|  x['date'] }.should == [today, today + 1]
    end
    
    it 'should return the array sorted by date' do
      today = Date.today
      @date_data.push({ 'date' => today + 1, 'hours' => 0, 'log' => [] })
      @date_data.push({ 'date' => today - 1, 'hours' => 0, 'log' => [] })
      @date_data.push({ 'date' => today,     'hours' => 0, 'log' => [] })
      @date_data.push({ 'date' => today + 1, 'hours' => 0, 'log' => [] })
      Freshtrack.group_date_data(@date_data).collect { |x|  x['date'] }.should == [today - 1, today, today + 1]
    end
    
    it 'should add the hours for a particular date' do
      today = Date.today
      @date_data.push({ 'date' => today,     'hours' => 1, 'log' => [] })
      @date_data.push({ 'date' => today,     'hours' => 3, 'log' => [] })
      @date_data.push({ 'date' => today + 1, 'hours' => 2, 'log' => [] })
      result = Freshtrack.group_date_data(@date_data)
      
      result[0]['date'].should  == today
      result[0]['hours'].should == 4
      
      result[1]['date'].should  == today + 1
      result[1]['hours'].should == 2
    end
    
    it 'should round the hours to two decimal places' do
      today = Date.today
      @date_data.push({ 'date' => today, 'hours' => 1.666666666, 'log' => [] })
      result = Freshtrack.group_date_data(@date_data)
      
      result[0]['date'].should  == today
      result[0]['hours'].should == 1.67
    end
    
    it 'should join the log into notes' do
      today = Date.today
      @date_data.push({ 'date' => today,     'hours' => 0, 'log' => ['punch in 1', 'punch out 1'] })
      @date_data.push({ 'date' => today,     'hours' => 0, 'log' => ['punch in 2', 'punch out 2'] })
      @date_data.push({ 'date' => today + 1, 'hours' => 0, 'log' => ['punch in 3', 'punch out 3'] })
      result = Freshtrack.group_date_data(@date_data)
      
      result[0]['date'].should  == today
      result[0]['notes'].should == "punch in 1\npunch out 1\n--------------------\npunch in 2\npunch out 2"
      result[0].should_not have_key('log')
      
      result[1]['date'].should  == today + 1
      result[1]['notes'].should == "punch in 3\npunch out 3"
      result[1].should_not have_key('log')
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
    
    it 'should accept an option string' do
      lambda { Freshtrack.get_data(@project_name, 'option string') }.should_not raise_error(ArgumentError)
    end
    
    it 'should get project data for supplied project' do
      Freshtrack.expects(:get_project_data).with(@project_name)
      Freshtrack.get_data(@project_name)
    end
    
    it 'should get time data for supplied project' do
      Freshtrack.expects(:get_time_data).with(@project_name, anything)
      Freshtrack.get_data(@project_name)
    end
    
    it 'should pass option string on when getting time data' do
      options = 'here be options'
      Freshtrack.expects(:get_time_data).with(@project_name, options)
      Freshtrack.get_data(@project_name, options)
    end
    
    it 'should default option string to empty string' do
      Freshtrack.expects(:get_time_data).with(@project_name, '')
      Freshtrack.get_data(@project_name)
    end
    
    it 'should return time data' do
      time_data = stub('time data')
      Freshtrack.stubs(:get_time_data).returns(time_data)
      Freshtrack.get_data(@project_name).should == time_data
    end
  end
  
  describe 'tracking time' do
    before :each do
      @project_name = :proj
      @data = []
      Freshtrack.stubs(:get_data).returns(@data)
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.track }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { Freshtrack.track(@project_name) }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept options' do
      lambda { Freshtrack.track(@project_name, :before => Time.now) }.should_not raise_error(ArgumentError)
    end
    
    it 'should get data for supplied project' do
      Freshtrack.expects(:get_data).with(@project_name, anything).returns(@data)
      Freshtrack.track(@project_name)
    end
    
    it 'should pass options on when getting data' do
      options = { :after => Time.now - 12345 }
      Freshtrack.expects(:get_data).with(@project_name, options).returns(@data)
      Freshtrack.track(@project_name, options)
    end
    
    it 'should default options to an empty hash' do
      Freshtrack.expects(:get_data).with(@project_name, {}).returns(@data)
      Freshtrack.track(@project_name)
    end
    
    it 'should create entries for project data' do
      2.times do
        ent = stub('entry data')
        @data.push(ent)
        Freshtrack.expects(:create_entry).with(ent)
      end
      Freshtrack.track(@project_name)
    end
  end
  
  describe 'creating an entry' do
    before :each do
      @date = Date.today - 3
      @hours = 5.67
      @notes = 'notes for the time entry'
      @entry_data = { 'date' => @date, 'hours' => @hours, 'notes' => @notes }
      @time_entry = stub('time entry', :project_id= => nil, :task_id= => nil, :date= => nil, :hours= => nil, :notes= => nil, :create => true)
      FreshBooks::TimeEntry.stubs(:new).returns(@time_entry)
      
      @project = stub('project', :project_id => stub('project id'))
      @task    = stub('task',    :task_id    => stub('task id'))
      Freshtrack.stubs(:project).returns(@project)
      Freshtrack.stubs(:task).returns(@task)
      
      STDERR.stubs(:puts)
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.create_entry }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { Freshtrack.create_entry(@entry_data) }.should_not raise_error(ArgumentError)
    end
    
    it 'should instantiate a new time entry' do
      FreshBooks::TimeEntry.expects(:new).returns(@time_entry)
      Freshtrack.create_entry(@entry_data)
    end
    
    describe 'with the time entry instance' do
      it 'should set the project' do
        @time_entry.expects(:project_id=).with(@project.project_id)
        Freshtrack.create_entry(@entry_data)
      end
      
      it 'should set the task' do
        @time_entry.expects(:task_id=).with(@task.task_id)
        Freshtrack.create_entry(@entry_data)
      end
      
      it 'should set the date' do
        @time_entry.expects(:date=).with(@date)
        Freshtrack.create_entry(@entry_data)
      end
      
      it 'should set the hours' do
        @time_entry.expects(:hours=).with(@hours)
        Freshtrack.create_entry(@entry_data)
      end
      
      it 'should set the notes' do
        @time_entry.expects(:notes=).with(@notes)
        Freshtrack.create_entry(@entry_data)
      end
    end
    
    it 'should create the time entry' do
      @time_entry.expects(:create)
      Freshtrack.create_entry(@entry_data)
    end
    
    describe 'successfully' do
      before :each do
        @time_entry.stubs(:create).returns(5)
      end
      
      it 'should be silent' do
        STDERR.expects(:puts).never
        Freshtrack.create_entry(@entry_data)
      end
      
      it 'should return true' do
        Freshtrack.create_entry(@entry_data).should be(true)
      end
    end
    
    describe 'unsuccessfully' do
      before :each do
        @time_entry.stubs(:create).returns(nil)
      end
      
      it 'should output an indication' do
        STDERR.expects(:puts).with(regexp_matches(/#{@date.to_s}/))
        Freshtrack.create_entry(@entry_data)
      end
      
      it 'should return nil' do
        Freshtrack.create_entry(@entry_data).should be_nil
      end
    end
  end
end
