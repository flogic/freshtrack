require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

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
  
  describe 'getting data' do
    before :each do
      @project_name = :proj
      Freshtrack.stubs(:get_project_data)
      @collector = stub('collector', :get_time_data => nil)
      Freshtrack.stubs(:collector).returns(@collector)
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.get_data }.should raise_error(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { Freshtrack.get_data(@project_name) }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept options' do
      lambda { Freshtrack.get_data(@project_name, :before => Time.now) }.should_not raise_error(ArgumentError)
    end
    
    it 'should get project data for supplied project' do
      Freshtrack.expects(:get_project_data).with(@project_name)
      Freshtrack.get_data(@project_name)
    end
    
    it 'should retrieve a time collector' do
      Freshtrack.expects(:collector).returns(@collector)
      Freshtrack.get_data(@project_name)
    end
    
    it 'should get time data for supplied project' do
      @collector.expects(:get_time_data).with(@project_name)
      Freshtrack.get_data(@project_name)
    end
    
    it 'should pass the options on when retrieving a time collector' do
      options = { :after => Time.now - 12345 }
      Freshtrack.expects(:collector).with(options).returns(@collector)
      Freshtrack.get_data(@project_name, options)
    end
    
    it 'should default options to an empty hash' do
      Freshtrack.expects(:collector).with({}).returns(@collector)
      Freshtrack.get_data(@project_name)
    end
    
    it 'should return time data' do
      time_data = stub('time data')
      @collector.stubs(:get_time_data).returns(time_data)
      Freshtrack.get_data(@project_name).should == time_data
    end
  end
  
  describe 'getting a collector' do
    module Freshtrack
      module TimeCollector
        class Punch
        end
        
        class OneInchPunch
        end
      end
    end
    
    before :each do
      Freshtrack.stubs(:config).returns({'collector' => 'punch' })
      @collector = stub('collector')
      Freshtrack::TimeCollector::Punch.stubs(:new).returns(@collector)
    end
    
    it 'should accept options' do
      lambda { Freshtrack.collector(:before => Time.now) }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require options' do
      lambda { Freshtrack.collector }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a library based on the collector given in the config' do
      Freshtrack.expects(:require).with('freshtrack/time_collectors/punch')
      Freshtrack.collector
    end
    
    it 'should create a collector object based on the collector given in the config' do
      Freshtrack::TimeCollector::Punch.expects(:new)
      Freshtrack.collector
    end
    
    it 'should pass the options on when creating a collector object' do
      options = { :before => Time.now }
      Freshtrack::TimeCollector::Punch.expects(:new).with(options)
      Freshtrack.collector(options)
    end
    
    it 'should pass an empty hash if no options given' do
      Freshtrack::TimeCollector::Punch.expects(:new).with({})
      Freshtrack.collector
    end
    
    it 'should return the collector' do
      Freshtrack.collector.should == @collector
    end
    
    it 'should error if no collector is given in the config' do
      Freshtrack.stubs(:config).returns({})
      lambda { Freshtrack.collector }.should raise_error
    end
    
    it "should accept a collector of 'punch'" do
      Freshtrack.stubs(:config).returns({'collector' => 'punch'})
      lambda { Freshtrack.collector }.should_not raise_error
    end
    
    it "should accept a collector of 'one_inch_punch'" do
      Freshtrack.stubs(:config).returns({'collector' => 'one_inch_punch'})
      Freshtrack::TimeCollector::OneInchPunch.stubs(:new)
      lambda { Freshtrack.collector }.should_not raise_error
    end
    
    it 'should correctly camel-case a collector name' do
      Freshtrack.stubs(:config).returns({'collector' => 'one_inch_punch'})
      Freshtrack::TimeCollector::OneInchPunch.expects(:new)
      Freshtrack.collector
    end
    
    it 'should error if an unknown collector is given in the config' do
      Freshtrack.stubs(:config).returns({'collector' => 'blam'})
      lambda { Freshtrack.collector }.should raise_error
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
  
  it 'should list open invoices' do
    Freshtrack.should respond_to(:open_invoices)
  end
  
  describe 'listing open invoices' do
    before :each do
      @invoices = Array.new(5) { stub('invoice', :open? => false) }
      FreshBooks::Invoice.stubs(:list).returns(@invoices)
    end
    
    it 'should get a list of invoices' do
      FreshBooks::Invoice.expects(:list).returns(@invoices)
      Freshtrack.open_invoices
    end
    
    it 'should return only the open invoices' do
      open_invoices = @invoices.values_at(0,1,2)
      open_invoices.each { |i|  i.stubs(:open?).returns(true) }
      
      Freshtrack.open_invoices.should == open_invoices
    end
    
    it 'should return an empty array if there are no open invoices' do
      Freshtrack.open_invoices.should == []
    end
    
    it 'should return an empty array if there are no invoices' do
      FreshBooks::Invoice.stubs(:list).returns([])
      Freshtrack.open_invoices.should == []
    end
    
    it 'should return an empty array if the invoice list returns nil' do
      FreshBooks::Invoice.stubs(:list).returns(nil)
      Freshtrack.open_invoices.should == []
    end
  end
end
