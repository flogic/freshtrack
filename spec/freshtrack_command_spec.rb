require File.dirname(__FILE__) + '/spec_helper.rb'

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
end
