require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe 'freshtrack command' do
  def run_command(*args)
    Object.const_set(:ARGV, args)
    begin
      eval File.read(File.join(File.dirname(__FILE__), *%w[.. bin freshtrack]))
    rescue SystemExit
    end
  end
  
  before :each do
    [:ARGV, :OPTIONS, :MANDATORY_OPTIONS].each do |const|
      Object.send(:remove_const, const) if Object.const_defined?(const)
    end
    
    Freshtrack.stubs(:init)
    Freshtrack.stubs(:track)
    
    @project = 'myproj'
  end
  
  it 'should exist' do
    lambda { run_command(@project) }.should_not raise_error(Errno::ENOENT)
  end
  
  it 'should require a project' do
    self.expects(:puts) { |text|  text.match(/usage.+project/i) }
    run_command
  end
  
  it 'should init Freshtrack' do
    Freshtrack.expects(:init)
    run_command(@project)
  end
  
  it 'should track time' do
    Freshtrack.expects(:track)
    run_command(@project)
  end
  
  it 'should track time for the given project' do
    Freshtrack.expects(:track).with(@project, anything)
    run_command(@project)
  end
  
  describe 'when options specified' do
    it "should pass on an 'after' time option given by --after" do
      time_option = '2008-08-26 09:47'
      time = Time.local(2008, 8, 26, 9, 47)
      Freshtrack.expects(:track).with(@project, has_entry(:after => time))
      run_command(@project, '--after', time_option)
    end

    it "should pass on a 'before' time option given by --before" do
      time_option = '2008-08-23 15:39'
      time = Time.local(2008, 8, 23, 15, 39)
      Freshtrack.expects(:track).with(@project, has_entry(:before => time))
      run_command(@project, '--before', time_option)
    end

    it 'should handle a time option given as a date' do
      time_option = '2008-08-23'
      time = Time.local(2008, 8, 23)
      Freshtrack.expects(:track).with(@project, has_entry(:before => time))
      run_command(@project, '--before', time_option)
    end
  end
  
  it 'should pass no options if none specified' do
    Freshtrack.expects(:track).with(@project, {})
    run_command(@project)
  end
  
  describe 'when --aging specified' do
    before :each do
      @aging_info = [
        { :id => 5,  :age => 31, :client => 'blah', :status => 'viewed' },
        { :id => 53, :age => 43, :client => 'bang', :status => 'sent' },
        { :id => 20, :age => 3,  :client => 'boom', :status => 'viewed' }
      ]
      Freshtrack.stubs(:invoice_aging).returns(@aging_info)
      self.stubs(:printf)
    end
    
    def aging_run
      run_command('--aging')
    end
    
    it 'should not require a project' do
      self.expects(:puts) { |text|  text.match(/usage.+project/i) }.never
      aging_run
    end
    
    it 'should init Freshtrack' do
      Freshtrack.expects(:init)
      aging_run
    end
    
    it 'should get the invoice aging information' do
      Freshtrack.expects(:invoice_aging).returns(@aging_info)
      aging_run
    end
    
    it 'should print the ID of each invoice' do
      pending 'making this actually test what it purports to'
      @aging_info.each do |info|
        self.expects(:printf) { |*args|  args.include?(info[:id]) }
      end
      aging_run
    end
    
    it 'should print the client of each invoice' do
      pending 'making this actually test what it purports to'
      @aging_info.each do |info|
        self.expects(:printf) { |*args|  args.include?(info[:client]) }
      end
      aging_run
    end
    
    it 'should print the age of each invoice' do
      pending 'making this actually test what it purports to'
      @aging_info.each do |info|
        self.expects(:printf) { |*args|  args.include?(info[:age]) }
      end
      aging_run
    end
    
    it 'should print the status of each invoice' do
      pending 'making this actually test what it purports to'
      @aging_info.each do |info|
        self.expects(:printf) { |*args|  args.include?(info[:status]) }
      end
      aging_run
    end
    
    it 'should not track time' do
      Freshtrack.expects(:track).never
      aging_run
    end
    
    it 'should not track time even when given a project' do
      Freshtrack.expects(:track).never
      run_command('--aging', @project)
    end
  end
end
