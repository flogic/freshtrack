require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe Integer do
  it 'should be convertible from seconds to hours' do
    90.should.respond_to(:secs_to_hours)
  end
  
  it 'should return this number of seconds as an amount of hours' do
    90.secs_to_hours.should == 0.025
  end
end

describe Float do
  it 'should be convertible from seconds to hours' do
    90.0.should.respond_to(:secs_to_hours)
  end
  
  it 'should return this number of seconds as an amount of hours' do
    90.0.secs_to_hours.should == 0.025
  end
end
