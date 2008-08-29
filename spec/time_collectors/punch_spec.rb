require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')
require 'freshtrack/time_collectors/punch'

describe Freshtrack::TimeCollector::Punch do
  before :each do
    @collector = Freshtrack::TimeCollector::Punch.new
  end
  
  describe 'when initialized' do
    it 'should accept options' do
      lambda { Freshtrack::TimeCollector::Punch.new(:before => Time.now) }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require options' do
      lambda { Freshtrack::TimeCollector::Punch.new }.should_not raise_error(ArgumentError)
    end
    
    it 'should provide access to the given options' do
      options = { :after => Time.now }
      Freshtrack::TimeCollector::Punch.new(options).options.should == options
    end
    
    it 'should default options to an empty hash' do
      Freshtrack::TimeCollector::Punch.new.options.should == {}
    end
  end
  
  it 'should get time data' do
    @collector.should respond_to(:get_time_data)
  end
  
  describe 'getting time data' do
    before :each do
      @project = 'myproj'
      @time_data = stub('time data')
      IO.stubs(:read).returns(@time_data)
      @collector.stubs(:convert_time_data)
      @collector.stubs(:condense_time_data)
    end
    
    it 'should accept a project' do
      lambda { @collector.get_time_data(@project) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a project' do
      lambda { @collector.get_time_data }.should raise_error(ArgumentError)
    end
    
    it 'should get the time data (from punch)' do
      IO.expects(:read).with(regexp_matches(/^\| punch list\b/))
      @collector.get_time_data(@project)
    end
    
    it 'should pass the supplied project when getting the time data' do
      IO.expects(:read).with(regexp_matches(/\b#{@project}\b/))
      @collector.get_time_data(@project)
    end
    
    it 'should pass the supplied options on as a string when getting the time data' do
      time = Time.local(2007, 3, 4, 13, 47, 56)
      options = { :after => time }
      option_str = '--after 2007-03-04T13:47:56-0500'
      @collector.stubs(:options).returns(options)
      IO.expects(:read).with(regexp_matches(/\b#{@project} #{option_str}\b/))
      @collector.get_time_data(@project)
    end
    
    it 'should default option string to empty string' do
      IO.expects(:read).with(regexp_matches(/\b#{@project} $/))
      @collector.get_time_data(@project)
    end
    
    it 'should convert the time data' do
      @collector.expects(:convert_time_data).with(@time_data)
      @collector.get_time_data(@project)
    end
    
    it 'should condense the converted time data' do
      converted_time_data = stub('converted time data')
      @collector.stubs(:convert_time_data).returns(converted_time_data)
      @collector.expects(:condense_time_data).with(converted_time_data)
      @collector.get_time_data(@project)
    end
    
    it 'should return the condensed data' do
      condensed = stub('condensed time data')
      @collector.stubs(:condense_time_data).returns(condensed)
      @collector.get_time_data(@project).should == condensed
    end
  end
  
  it 'should convert time data' do
    @collector.should respond_to(:convert_time_data)
  end
  
  describe 'converting time data' do
    before :each do
      @time_data = stub('time data')
      YAML.stubs(:load)
      @collector.stubs(:condense_time_data)
    end
    
    it 'should accept time data' do
      lambda { @collector.convert_time_data(@time_data) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require time data' do
      lambda { @collector.convert_time_data }.should raise_error(ArgumentError)
    end

    it 'should convert the time data from YAML' do
      YAML.expects(:load).with(@time_data)
      @collector.convert_time_data(@time_data)
    end
    
    it 'should return the converted time data' do
      converted = stub('converted time data')
      YAML.stubs(:load).returns(converted)
      @collector.convert_time_data(@time_data).should == converted
    end
  end
  
  it 'should condense time data' do
    @collector.should respond_to(:condense_time_data)
  end
  
  describe 'condensing time data' do
    before :each do
      @time_data = stub('time data')
      @collector.stubs(:times_to_dates)
      @collector.stubs(:group_date_data)
    end
    
    it 'should accept time data' do
      lambda { @collector.condense_time_data(@time_data) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require time data' do
      lambda { @collector.condense_time_data }.should raise_error(ArgumentError)
    end
    
    it 'should convert times to dates and hour differences' do
      @collector.expects(:times_to_dates).with(@time_data)
      @collector.condense_time_data(@time_data)
    end
    
    it 'should group date and hour differences' do
      date_hour_data = stub('date/hour data')
      @collector.stubs(:times_to_dates).returns(date_hour_data)
      @collector.expects(:group_date_data).with(date_hour_data)
      @collector.condense_time_data(@time_data)
    end
    
    it 'should return the grouped date/hour data' do
      grouped_dates = stub('grouped date/hour data')
      @collector.stubs(:group_date_data).returns(grouped_dates)
      @collector.condense_time_data(@time_data).should == grouped_dates
    end
  end
  
  it 'should convert times to dates and hour differences' do
    @collector.should respond_to(:times_to_dates)
  end
  
  describe 'converting times to dates and hour differences' do
    before :each do
      @time_data = []
    end
    
    it 'should accept time data' do
      lambda { @collector.times_to_dates(@time_data) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require time data' do
      lambda { @collector.times_to_dates }.should raise_error(ArgumentError)
    end
    
    it 'should return an array' do
      @collector.times_to_dates(@time_data).should be_kind_of(Array)
    end
    
    it 'should replace the in/out time data with a single date' do
      @time_data.push({ 'in' => Time.local(2008, 1, 25, 6,  25, 0), 'out' => Time.local(2008, 1, 25, 7,  25, 0) })
      result = @collector.times_to_dates(@time_data)
      result = result.first
      
      result.should     have_key('date')
      result.should_not have_key('in')
      result.should_not have_key('out')
    end
    
    it 'should make the date appopriate to the time' do
      @time_data.push({ 'in' => Time.local(2008, 1, 25, 6,  25, 0), 'out' => Time.local(2008, 1, 25, 7,  25, 0) })
      result = @collector.times_to_dates(@time_data)
      result = result.first
      result['date'].should == Date.civil(2008, 1, 25)
    end
    
    it 'should use the in time date' do
      @time_data.push({ 'in' => Time.local(2008, 1, 25, 6,  25, 0), 'out' => Time.local(2008, 1, 26, 7,  25, 0) })
      result = @collector.times_to_dates(@time_data)
      result = result.first
      result['date'].should == Date.civil(2008, 1, 25)
    end
    
    it 'should add hour data' do
      @time_data.push({ 'in' => Time.local(2008, 1, 25, 6,  25, 0), 'out' => Time.local(2008, 1, 25, 7,  25, 0) })
      result = @collector.times_to_dates(@time_data)
      result = result.first
      result.should have_key('hours')
    end
    
    it 'should make the hour data appropriate to the in/out difference' do
      @time_data.push({ 'in' => Time.local(2008, 1, 25, 6,  25, 0), 'out' => Time.local(2008, 1, 25, 7,  55, 0) })
      result = @collector.times_to_dates(@time_data)
      result = result.first
      result['hours'].should == 1.5
    end
  end
  
  it 'should group date data' do
    @collector.should respond_to(:group_date_data)
  end
  
  describe 'grouping date data' do
    before :each do
      @date_data = []
    end
    
    it 'should accept date data' do
      lambda { @collector.group_date_data(@date_data) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require date data' do
      lambda { @collector.group_date_data }.should raise_error(ArgumentError)
    end
    
    it 'should return an array' do
      @collector.group_date_data(@date_data).should be_kind_of(Array)
    end
    
    it 'should group the data by date' do
      today = Date.today
      @date_data.push({ 'date' => today,     'hours' => 0, 'log' => [] })
      @date_data.push({ 'date' => today,     'hours' => 0, 'log' => [] })
      @date_data.push({ 'date' => today + 1, 'hours' => 0, 'log' => [] })
      @collector.group_date_data(@date_data).collect { |x|  x['date'] }.should == [today, today + 1]
    end
    
    it 'should return the array sorted by date' do
      today = Date.today
      @date_data.push({ 'date' => today + 1, 'hours' => 0, 'log' => [] })
      @date_data.push({ 'date' => today - 1, 'hours' => 0, 'log' => [] })
      @date_data.push({ 'date' => today,     'hours' => 0, 'log' => [] })
      @date_data.push({ 'date' => today + 1, 'hours' => 0, 'log' => [] })
      @collector.group_date_data(@date_data).collect { |x|  x['date'] }.should == [today - 1, today, today + 1]
    end
    
    it 'should add the hours for a particular date' do
      today = Date.today
      @date_data.push({ 'date' => today,     'hours' => 1, 'log' => [] })
      @date_data.push({ 'date' => today,     'hours' => 3, 'log' => [] })
      @date_data.push({ 'date' => today + 1, 'hours' => 2, 'log' => [] })
      result = @collector.group_date_data(@date_data)
      
      result[0]['date'].should  == today
      result[0]['hours'].should == 4
      
      result[1]['date'].should  == today + 1
      result[1]['hours'].should == 2
    end
    
    it 'should round the hours to two decimal places' do
      today = Date.today
      @date_data.push({ 'date' => today, 'hours' => 1.666666666, 'log' => [] })
      result = @collector.group_date_data(@date_data)
      
      result[0]['date'].should  == today
      result[0]['hours'].should == 1.67
    end
    
    it 'should join the log into notes' do
      today = Date.today
      @date_data.push({ 'date' => today,     'hours' => 0, 'log' => ['punch in 1', 'punch out 1'] })
      @date_data.push({ 'date' => today,     'hours' => 0, 'log' => ['punch in 2', 'punch out 2'] })
      @date_data.push({ 'date' => today + 1, 'hours' => 0, 'log' => ['punch in 3', 'punch out 3'] })
      result = @collector.group_date_data(@date_data)
      
      result[0]['date'].should  == today
      result[0]['notes'].should == "punch in 1\npunch out 1\n--------------------\npunch in 2\npunch out 2"
      result[0].should_not have_key('log')
      
      result[1]['date'].should  == today + 1
      result[1]['notes'].should == "punch in 3\npunch out 3"
      result[1].should_not have_key('log')
    end
  end
end
