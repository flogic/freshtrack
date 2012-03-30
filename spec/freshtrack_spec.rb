require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe Freshtrack do
  describe 'loading configuration' do
    before do
      File.stub!(:read).and_return('')
    end
    
    it 'should load the contents of the .freshtrack.yml file' do
      File.stub!(:expand_path).with('~/.freshtrack.yml').and_return('~/.freshtrack.yml')
      File.should.receive(:read).with('~/.freshtrack.yml').and_return('')
      Freshtrack.load_config
    end
    
    it 'should turn the file contents into data' do
      file_contents = mock('lorem ipsum')
      File.stub!(:read).and_return(file_contents)
      YAML.should.receive(:load).with(file_contents)
      Freshtrack.load_config
    end
    
    it 'should store the configuration data' do
      config = mock('config data')
      YAML.stub!(:load).and_return(config)
      Freshtrack.load_config
      Freshtrack.config.should == config
    end
  end
    
  describe 'getting configuration data' do
    before do
      @config = {
        'collector' => 'one_inch_punch',
        'company'   => 'comptastic',
        'token'     => '13984ujaslkdfj0932',
        'project_task_mapping' => {
          'projone' => { :project => 'ProjectOne',  :task => 'ProjectOneTask' },
          'projtwo' => { :project => 'Project_Two', :task => 'Project_Two_Task' }
        }
      }
      Freshtrack.stub!(:config).and_return(@config)
    end
    
    it 'should provide easy access to the project/task mapping' do
      Freshtrack.project_task_mapping.should == @config['project_task_mapping']
    end
    
    describe 'when no project name is set' do
      before do
        Freshtrack.stub!(:project_name).and_return(nil)
      end
      
      it 'should provide easy access to the top-level company' do
        Freshtrack.company.should == @config['company']
      end
      
      it 'should provide easy access to the top-level token' do
        Freshtrack.token.should == @config['token']
      end
      
      it 'should return nil for the company if no top-level company is set' do
        @config.delete('company')
        Freshtrack.company.should.be.nil
      end
      
      it 'should return nil for the token if no top-level token is set' do
        @config.delete('token')
        Freshtrack.token.should.be.nil
      end
    end
    
    describe 'when a project name is set' do 
      before do
        @project_name = 'projone'
        Freshtrack.stub!(:project_name).and_return(@project_name)
      end
      
      describe 'and the project has no company info set' do
        before do
          @config['project_task_mapping'][@project_name].delete(:company)
          @config['project_task_mapping'][@project_name].delete(:token)
        end
        
        it 'should provide easy access to the top-level company' do
          Freshtrack.company.should == @config['company']
        end
    
        it 'should provide easy access to the top-level token' do
          Freshtrack.token.should == @config['token']
        end
      end
      
      describe 'and the project has company info set' do
        before do
          @project_company = 'special_company'
          @project_token   = '134oiujasdlfkj309'
          @config['project_task_mapping'][@project_name][:company] = @project_company
          @config['project_task_mapping'][@project_name][:token]   = @project_token
        end
        
        it 'should provide easy access to the project-level company' do
          Freshtrack.company.should == @project_company
        end
    
        it 'should provide easy access to the project-level token' do
          Freshtrack.token.should == @project_token
        end
        
        describe 'and the info is incomplete' do
          it 'should provide easy access to the top-level company and token if the project-level company is missing' do
            @config['project_task_mapping'][@project_name].delete(:company)
            Freshtrack.company.should == @config['company']
            Freshtrack.token.should   == @config['token']
          end

          it 'should provide easy access to the top-level company and token if the project-level token is missing' do
            @config['project_task_mapping'][@project_name].delete(:token)
            Freshtrack.company.should == @config['company']
            Freshtrack.token.should   == @config['token']
          end
        end
      end
    end
  end
  
  describe 'initialization' do
    before do
      @project_name = 'the_project'
      @company = 'zee_company_boss'
      @token = 'token goes here'
      Freshtrack.stub!(:load_config)
      Freshtrack.stub!(:company).and_return(@company)
      Freshtrack.stub!(:token).and_return(@token)
    end
    
    it 'should accept a project name' do
      lambda { Freshtrack.init(@project_name) }.should.not.raise(ArgumentError)
    end
    
    it 'should not require a project name' do
      lambda { Freshtrack.init }.should.not.raise(ArgumentError)
    end
    
    it 'should provide easy access to the project name' do
      Freshtrack.init(@project_name)
      Freshtrack.project_name.should == @project_name
    end
    
    it 'should default the project name to nil' do
      Freshtrack.init
      Freshtrack.project_name.should.be.nil
    end
    
    it 'should load the configuration' do
      Freshtrack.should.receive(:load_config)
      Freshtrack.init
    end
    
    it 'should use the config data to set up FreshBooks' do
      FreshBooks.should.receive(:setup).with("#{@company}.freshbooks.com", @token)
      Freshtrack.init
    end
  end
  
  describe 'getting project data' do
    before do
      @project_name = :proj
      @project_task_mapping = { @project_name => { :project => 'fb proj', :task => 'fb task' } }
      Freshtrack.stub!(:project_task_mapping).and_return(@project_task_mapping)
      @project = mock('project')
      @task = mock('task')
      FreshBooks::Project.stub!(:find_by_name).and_return(@project)
      FreshBooks::Task.stub!(:find_by_name).and_return(@task)
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.get_project_data }.should.raise(ArgumentError)
    end
    it 'should accept an argument' do
      lambda { Freshtrack.get_project_data(@project_name) }.should.not.raise(ArgumentError)
    end
    
    it 'should require the argument to be a valid project identifier' do
      @project_task_mapping.delete(@project_name)
      lambda { Freshtrack.get_project_data(@project_name) }.should.raise
    end
    
    it 'should accept an argument that is a valid project identifier' do
      lambda { Freshtrack.get_project_data(@project_name) }.should.not.raise
    end
    
    it 'should get the indicated FreshBooks project' do
      FreshBooks::Project.should.receive(:find_by_name).with(@project_task_mapping[@project_name][:project]).and_return(@project)
      Freshtrack.get_project_data(@project_name)
    end
    
    it 'should abort if no FreshBooks project found' do
      FreshBooks::Project.stub!(:find_by_name).and_return(nil)
      lambda { Freshtrack.get_project_data(@project_name) }.should.raise
    end
    
    it 'should provide easy access to the project' do
      FreshBooks::Project.stub!(:find_by_name).and_return(@project)
      Freshtrack.get_project_data(@project_name)
      Freshtrack.project.should == @project
    end
    
    it 'should get the indicated FreshBooks task' do
      FreshBooks::Task.should.receive(:find_by_name).with(@project_task_mapping[@project_name][:task]).and_return(@task)
      Freshtrack.get_project_data(@project_name)
    end
    
    it 'should abort if no FreshBooks task found' do
      FreshBooks::Task.stub!(:find_by_name).and_return(nil)
      lambda { Freshtrack.get_project_data(@project_name) }.should.raise
    end
    
    it 'should provide easy access to the task' do
      FreshBooks::Task.stub!(:find_by_name).and_return(@task)
      Freshtrack.get_project_data(@project_name)
      Freshtrack.task.should == @task
    end
  end
  
  describe 'getting data' do
    before do
      @project_name = :proj
      Freshtrack.stub!(:get_project_data)
      @collector = mock('collector', :get_time_data => nil)
      Freshtrack.stub!(:collector).and_return(@collector)
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.get_data }.should.raise(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { Freshtrack.get_data(@project_name) }.should.not.raise(ArgumentError)
    end
    
    it 'should accept options' do
      lambda { Freshtrack.get_data(@project_name, :before => Time.now) }.should.not.raise(ArgumentError)
    end
    
    it 'should get project data for supplied project' do
      Freshtrack.should.receive(:get_project_data).with(@project_name)
      Freshtrack.get_data(@project_name)
    end
    
    it 'should retrieve a time collector' do
      Freshtrack.should.receive(:collector).and_return(@collector)
      Freshtrack.get_data(@project_name)
    end
    
    it 'should get time data for supplied project' do
      @collector.should.receive(:get_time_data).with(@project_name)
      Freshtrack.get_data(@project_name)
    end
    
    it 'should pass the options on when retrieving a time collector' do
      options = { :after => Time.now - 12345 }
      Freshtrack.should.receive(:collector).with(options).and_return(@collector)
      Freshtrack.get_data(@project_name, options)
    end
    
    it 'should default options to an empty hash' do
      Freshtrack.should.receive(:collector).with({}).and_return(@collector)
      Freshtrack.get_data(@project_name)
    end
    
    it 'should return time data' do
      time_data = mock('time data')
      @collector.stub!(:get_time_data).and_return(time_data)
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
    
    before do
      Freshtrack.stub!(:config).and_return({'collector' => 'punch' })
      @collector = mock('collector')
      Freshtrack::TimeCollector::Punch.stub!(:new).and_return(@collector)
    end
    
    it 'should accept options' do
      lambda { Freshtrack.collector(:before => Time.now) }.should.not.raise(ArgumentError)
    end
    
    it 'should not require options' do
      lambda { Freshtrack.collector }.should.not.raise(ArgumentError)
    end
    
    it 'should require a library based on the collector given in the config' do
      # this expectation makes facon go crazy with `require` in the rest of the specs
      # Freshtrack.should.receive(:require) do |arg|
      #   arg.should == 'freshtrack/time_collectors/punch'
      # end      
      Freshtrack.collector
    end
    
    it 'should create a collector object based on the collector given in the config' do
      Freshtrack::TimeCollector::Punch.should.receive(:new)
      Freshtrack.collector
    end
    
    it 'should pass the options on when creating a collector object' do
      options = { :before => Time.now }
      Freshtrack::TimeCollector::Punch.should.receive(:new).with(options)
      Freshtrack.collector(options)
    end
    
    it 'should pass an empty hash if no options given' do
      Freshtrack::TimeCollector::Punch.should.receive(:new).with({})
      Freshtrack.collector
    end
    
    it 'should return the collector' do
      Freshtrack.collector.should == @collector
    end
    
    it 'should error if no collector is given in the config' do
      Freshtrack.stub!(:config).and_return({})
      lambda { Freshtrack.collector }.should.raise(StandardError)
    end
    
    it "should accept a collector of 'punch'" do
      Freshtrack.stub!(:config).and_return({'collector' => 'punch'})
      lambda { Freshtrack.collector }.should.not.raise
    end
    
    it "should accept a collector of 'one_inch_punch'" do
      Freshtrack.stub!(:config).and_return({'collector' => 'one_inch_punch'})
      Freshtrack::TimeCollector::OneInchPunch.stub!(:new)
      lambda { Freshtrack.collector }.should.not.raise
    end
    
    it 'should correctly camel-case a collector name' do
      Freshtrack.stub!(:config).and_return({'collector' => 'one_inch_punch'})
      Freshtrack::TimeCollector::OneInchPunch.should.receive(:new)
      Freshtrack.collector
    end
    
    it 'should error if an unknown collector is given in the config' do
      Freshtrack.stub!(:config).and_return({'collector' => 'blam'})
      lambda { Freshtrack.collector }.should.raise(LoadError)
    end
  end
  
  describe 'tracking time' do
    before do
      @project_name = :proj
      @data = []
      Freshtrack.stub!(:get_data).and_return(@data)
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.track }.should.raise(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { Freshtrack.track(@project_name) }.should.not.raise(ArgumentError)
    end
    
    it 'should accept options' do
      lambda { Freshtrack.track(@project_name, :before => Time.now) }.should.not.raise(ArgumentError)
    end
    
    it 'should get data for supplied project' do
      Freshtrack.should.receive(:get_data).and_return(@data) do |project, _|
        project.should == @project_name
      end
      Freshtrack.track(@project_name)
    end
    
    it 'should pass options on when getting data' do
      options = { :after => Time.now - 12345 }
      Freshtrack.should.receive(:get_data).and_return(@data) do |project, opts|
        project.should == @project_name
        opts.should == options
      end
      Freshtrack.track(@project_name, options)
    end
    
    it 'should default options to an empty hash' do
      Freshtrack.should.receive(:get_data).and_return(@data) do |project, opts|
        project.should == @project_name
        opts.should == {}
      end
      Freshtrack.track(@project_name)
    end
    
    it 'should create entries for project data' do
      2.times do
        ent = mock('entry data')
        @data.push(ent)
        Freshtrack.should.receive(:create_entry).with(ent)
      end
      Freshtrack.track(@project_name)
    end
  end
  
  describe 'creating an entry' do
    before do
      @date = Date.today - 3
      @hours = 5.67
      @notes = 'notes for the time entry'
      @entry_data = { 'date' => @date, 'hours' => @hours, 'notes' => @notes }
      @time_entry = mock('time entry', :project_id= => nil, :task_id= => nil, :date= => nil, :hours= => nil, :notes= => nil, :create => true)
      FreshBooks::TimeEntry.stub!(:new).and_return(@time_entry)
      
      @project = mock('project', :project_id => mock('project id'))
      @task    = mock('task',    :task_id    => mock('task id'))
      Freshtrack.stub!(:project).and_return(@project)
      Freshtrack.stub!(:task).and_return(@task)
      
      STDERR.stub!(:puts)
    end
    
    it 'should require an argument' do
      lambda { Freshtrack.create_entry }.should.raise(ArgumentError)
    end
    
    it 'should accept an argument' do
      lambda { Freshtrack.create_entry(@entry_data) }.should.not.raise(ArgumentError)
    end
    
    it 'should instantiate a new time entry' do
      FreshBooks::TimeEntry.should.receive(:new).and_return(@time_entry)
      Freshtrack.create_entry(@entry_data)
    end
    
    describe 'with the time entry instance' do
      it 'should set the project' do
        @time_entry.should.receive(:project_id=).with(@project.project_id)
        Freshtrack.create_entry(@entry_data)
      end
      
      it 'should set the task' do
        @time_entry.should.receive(:task_id=).with(@task.task_id)
        Freshtrack.create_entry(@entry_data)
      end
      
      it 'should set the date' do
        @time_entry.should.receive(:date=).with(@date)
        Freshtrack.create_entry(@entry_data)
      end
      
      it 'should set the hours' do
        @time_entry.should.receive(:hours=).with(@hours)
        Freshtrack.create_entry(@entry_data)
      end
      
      it 'should set the notes' do
        @time_entry.should.receive(:notes=).with(@notes)
        Freshtrack.create_entry(@entry_data)
      end
    end
    
    it 'should create the time entry' do
      @time_entry.should.receive(:create)
      Freshtrack.create_entry(@entry_data)
    end
    
    describe 'successfully' do
      before do
        @time_entry.stub!(:create).and_return(5)
      end
      
      it 'should be silent' do
        STDERR.should.receive(:puts).never
        Freshtrack.create_entry(@entry_data)
      end
      
      it 'should return true' do
        Freshtrack.create_entry(@entry_data).should == true
      end
    end
    
    describe 'unsuccessfully' do
      before do
        @time_entry.stub!(:create).and_return(nil)
      end
      
      it 'should output an indication' do
        STDERR.should.receive(:puts) do |arg|
          arg.should.match(/#{@date.to_s}/)
        end
        Freshtrack.create_entry(@entry_data)
      end
      
      it 'should return nil' do
        Freshtrack.create_entry(@entry_data).should.be.nil
      end
    end
  end
  
  it 'should list open invoices' do
    Freshtrack.should.respond_to(:open_invoices)
  end
  
  describe 'listing open invoices' do
    before do
      @invoices = Array.new(5) { mock('invoice', :open? => false) }
      FreshBooks::Invoice.stub!(:list).and_return(@invoices)
    end
    
    it 'should get a list of invoices' do
      FreshBooks::Invoice.should.receive(:list).and_return(@invoices)
      Freshtrack.open_invoices
    end
    
    it 'should return only the open invoices' do
      open_invoices = @invoices.values_at(0,1,2)
      open_invoices.each { |i|  i.stub!(:open?).and_return(true) }
      
      Freshtrack.open_invoices.should == open_invoices
    end
    
    it 'should return an empty array if there are no open invoices' do
      Freshtrack.open_invoices.should == []
    end
    
    it 'should return an empty array if there are no invoices' do
      FreshBooks::Invoice.stub!(:list).and_return([])
      Freshtrack.open_invoices.should == []
    end
    
    it 'should return an empty array if the invoice list returns nil' do
      FreshBooks::Invoice.stub!(:list).and_return(nil)
      Freshtrack.open_invoices.should == []
    end
  end
  
  it 'should show invoice aging' do
    Freshtrack.should.respond_to(:invoice_aging)
  end
  
  describe 'showing invoice aging' do
    before do
      today = Date.today
      
      @invoices = [
        mock('invoice', :invoice_id => '1234',  :number => '4567',  :client => mock('client', :organization => 'client 20'), :date => today - 3,  :status => 'partial', :amount => 50, :owed_amount => 3),
        mock('invoice', :invoice_id => '19873', :number => '1456',  :client => mock('client', :organization => 'client 3'),  :date => today - 20, :status => 'viewed',  :amount => 60, :owed_amount => 60),
        mock('invoice', :invoice_id => '0038',  :number => '30267', :client => mock('client', :organization => 'client 4'),  :date => today - 59, :status => 'sent',    :amount => 20, :owed_amount => 20)
      ]
      Freshtrack.stub!(:open_invoices).and_return(@invoices)
    end
    
    it 'should get open invoices' do
      Freshtrack.should.receive(:open_invoices).and_return(@invoices)
      Freshtrack.invoice_aging
    end
    
    it 'should extract the ID for each open invoice' do
      ids = @invoices.collect { |i|  i.invoice_id }
      Freshtrack.invoice_aging.collect { |i| i[:id] }.should == ids
    end
    
    it 'should extract the number for each open invoice' do
      numbers = @invoices.collect { |i|  i.number }
      Freshtrack.invoice_aging.collect { |i| i[:number] }.should == numbers
    end
    
    it 'should extract the client for each open invoice' do
      clients = @invoices.collect { |i|  i.client.organization }
      Freshtrack.invoice_aging.collect { |i| i[:client] }.should == clients
    end
    
    it 'should extract the age for each open invoice' do
      Freshtrack.invoice_aging.collect { |i| i[:age] }.should == [3, 20, 59]
    end
    
    it 'should extract the status for each open invoice' do
      statuses = @invoices.collect { |i|  i.status }
      Freshtrack.invoice_aging.collect { |i| i[:status] }.should == statuses
    end
    
    it 'should extract the amount for each open invoice' do
      amounts = @invoices.collect { |i|  i.amount }
      Freshtrack.invoice_aging.collect { |i| i[:amount] }.should == amounts
    end
    
    it 'should extract the owed amount for each open invoice' do
      oweds = @invoices.collect { |i|  i.owed_amount }
      Freshtrack.invoice_aging.collect { |i| i[:owed] }.should == oweds
    end
    
    it 'should return an empty array if there are no open invoices' do
      Freshtrack.stub!(:open_invoices).and_return([])
      Freshtrack.invoice_aging.should == []
    end
  end

  it 'should get time spent on a project' do
    Freshtrack.should.respond_to(:time_spent)
  end

  describe 'getting time spent on a project' do
    before do
      @project_name = :proj
      @time_entries = Array.new(3) { mock('time_entry', :hours => rand(10)) }
      Freshtrack.stub!(:get_time_entries).and_return(@time_entries)
    end

    it 'should require a project name' do
      lambda { Freshtrack.time_spent }.should.raise(ArgumentError)
    end

    it 'should accept a project name' do
      lambda { Freshtrack.time_spent(@project_name) }.should.not.raise(ArgumentError)
    end

    it 'should get time entries for the given project' do
      Freshtrack.should.receive(:get_time_entries).with(@project_name).and_return(@time_entries)
      Freshtrack.time_spent(@project_name)
    end

    it 'should return the sum total hours of the time entries' do
      total = @time_entries.collect(&:hours).inject(&:+)
      Freshtrack.time_spent(@project_name).should == total
    end
  end

  it 'should get time entries for a project' do
    Freshtrack.should.respond_to(:get_time_entries)
  end

  describe 'getting time entries for a project' do
    before do
      @project_name = :proj
      Freshtrack.stub!(:get_project_data)
      @project_id = 7
      @project = mock('project', :project_id => @project_id)
      Freshtrack.instance_variable_set('@project', @project)
      @time_entries = Array.new(3) { mock('time entry') }
      FreshBooks::TimeEntry.stub!(:list).and_return(@time_entries)
    end

    it 'should require a project name' do
      lambda { Freshtrack.get_time_entries }.should.raise(ArgumentError)
    end

    it 'should accept a project name' do
      lambda { Freshtrack.get_time_entries(@project_name) }.should.not.raise(ArgumentError)
    end

    it 'should get project data for the given project name' do
      Freshtrack.should.receive(:get_project_data).with(@project_name)
      Freshtrack.get_time_entries(@project_name)
    end

    it 'should get time entries for the project (based on ID)' do
      FreshBooks::TimeEntry.should.receive(:list).with('project_id' => @project_id)
      Freshtrack.get_time_entries(@project_name)
    end

    it 'should return the time entries' do
      Freshtrack.get_time_entries(@project_name).should == @time_entries
    end
  end
end
