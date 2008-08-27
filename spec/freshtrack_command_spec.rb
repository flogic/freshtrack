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
  
  it 'should pass arguments on when tracking time' do
    Freshtrack.expects(:track).with(anything, '--after 2008-08-26')
    run_command(@project, '--after', '2008-08-26')
  end
end
