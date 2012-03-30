require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

def run_command(*args)
  Object.const_set(:ARGV, args)
  begin
    eval File.read(File.join(File.dirname(__FILE__), *%w[.. bin freshtrack]))
  rescue SystemExit
  end
end

def pending(*args, &block)
end

describe 'freshtrack command' do
  before do
    [:ARGV, :OPTIONS, :MANDATORY_OPTIONS].each do |const|
      Object.send(:remove_const, const) if Object.const_defined?(const)
    end
    
    Freshtrack.stub!(:init)
    Freshtrack.stub!(:track)
    
    @project = 'myproj'
  end
  
  it 'should exist' do
    lambda { run_command(@project) }.should.not.raise(Errno::ENOENT)
  end
  
  it 'should require a project' do
    self.should.receive(:puts) { |text|  text.match(/usage.+project/i) }
    run_command
  end
  
  it 'should init Freshtrack with the given project' do
    Freshtrack.should.receive(:init) do |arg|
      arg.should == @project
    end
    run_command(@project)
  end
  
  it 'should track time' do
    Freshtrack.should.receive(:track)
    run_command(@project)
  end
  
  it 'should track time for the given project' do
    Freshtrack.should.receive(:track) do |project, _|
      project.should == @project
    end
    run_command(@project)
  end
  
  describe 'when options specified' do
    it "should pass on an 'after' time option given by --after" do
      time_option = '2008-08-26 09:47'
      time = Time.local(2008, 8, 26, 9, 47)
      Freshtrack.should.receive(:track) do |project, opts|
        project.should == @project
        opts[:after].should == time
      end
      run_command(@project, '--after', time_option)
    end

    it "should pass on a 'before' time option given by --before" do
      time_option = '2008-08-23 15:39'
      time = Time.local(2008, 8, 23, 15, 39)
      Freshtrack.should.receive(:track) do |project, opts|
        project.should == @project
        opts[:before].should == time
      end
      run_command(@project, '--before', time_option)
    end

    it 'should handle a time option given as a date' do
      time_option = '2008-08-23'
      time = Time.local(2008, 8, 23)
      Freshtrack.should.receive(:track) do |project, opts|
        project.should == @project
        opts[:before].should == time
      end
      run_command(@project, '--before', time_option)
    end
  end
  
  it 'should pass no options if none specified' do
    Freshtrack.should.receive(:track).with(@project, {})
    run_command(@project)
  end
  
  describe 'when --aging specified' do
    before do
      @aging_info = [
        { :id => 5,  :number => '123', :age => 31, :client => 'blah', :status => 'viewed', :amount => 123.3, :owed => 5.67 },
        { :id => 53, :number => '234', :age => 43, :client => 'bang', :status => 'sent',   :amount => 60.0,  :owed => 60.0 },
        { :id => 20, :number => '938', :age => 3,  :client => 'boom', :status => 'viewed', :amount => 100.0, :owed => 100.0 }
      ]
      Freshtrack.stub!(:invoice_aging).and_return(@aging_info)
      self.stub!(:printf)
    end
    
    def aging_run(project=nil)
      args = [project, '--aging'].compact
      run_command(*args)
    end
    
    it 'should not require a project' do
      self.should.receive(:puts) { |text|  text.match(/usage.+project/i) }.never
      aging_run
    end
    
    it 'should init Freshtrack with a project if given' do
      Freshtrack.should.receive(:init) do |arg|
        arg.should == @project
      end
      aging_run(@project)
    end
    
    it 'should init Freshtrack for no project if none given' do
      Freshtrack.should.receive(:init) do |arg|
        arg.should.be.nil
      end
      aging_run
    end
    
    it 'should get the invoice aging information' do
      Freshtrack.should.receive(:invoice_aging).and_return(@aging_info)
      aging_run
    end
    
    it 'should print the number of each invoice' do
      pending 'making this actually test what it purports to' do
      @aging_info.each do |info|
        self.should.receive(:printf) { |*args|  args.should.include(info[:number]) }
      end
      aging_run
      end
    end
    
    it 'should print the client of each invoice' do
      pending 'making this actually test what it purports to' do
      @aging_info.each do |info|
        self.should.receive(:printf) { |*args|  args.should.include(info[:client]) }
      end
      aging_run
      end
    end
    
    it 'should print the age of each invoice' do
      pending 'making this actually test what it purports to' do
      @aging_info.each do |info|
        self.should.receive(:printf) { |*args|  args.should.include(info[:age]) }
      end
      aging_run
      end
    end
    
    it 'should print the status of each invoice' do
      pending 'making this actually test what it purports to' do
      @aging_info.each do |info|
        self.should.receive(:printf) { |*args|  args.should.include(info[:status]) }
      end
      aging_run
      end
    end
    
    it 'should print the amount of each invoice' do
      pending 'making this actually test what it purports to' do
      @aging_info.each do |info|
        self.should.receive(:printf) { |*args|  args.should.include(info[:amount]) }
      end
      aging_run
      end
    end
    
    it 'should print the owed of each invoice' do
      pending 'making this actually test what it purports to' do
      @aging_info.each do |info|
        self.should.receive(:printf) { |*args|  args.should.include(info[:owed]) }
      end
      aging_run
      end
    end
    
    it 'should not track time' do
      Freshtrack.should.receive(:track).never
      aging_run
    end
    
    it 'should not track time even when given a project' do
      Freshtrack.should.receive(:track).never
      aging_run(@project)
    end
  end

  describe 'when --unbilled specified' do
    before do
      @time_info = 37.5
      Freshtrack.stub!(:unbilled_time).and_return(@time_info)
      self.stub!(:puts)
    end
    
    def unbilled_run(project = nil)
      args = ['--unbilled', project].compact
      run_command(*args)
    end
    
    it 'should require a project value for the option' do
      self.should.receive(:puts) { |text|  text.to_s.match(/project.+required/i) }
      unbilled_run(@project)
    end
    
    it 'should init Freshtrack with the given project' do
      Freshtrack.should.receive(:init) do |arg|
        arg.should == @project
      end
      unbilled_run(@project)
    end
    
    it 'should get the unbilled time info for the given project' do
      Freshtrack.should.receive(:unbilled_time).with(@project)
      unbilled_run(@project)
    end

    it 'should output the unbilled time' do
      self.should.receive(:puts) { |text|  text.to_s.match(Regexp.new(Regexp.escape(@time_info.to_s))) }
      unbilled_run(@project)
    end

    it 'should not track time' do
      Freshtrack.should.receive(:track).never
      unbilled_run
    end
  end
end
