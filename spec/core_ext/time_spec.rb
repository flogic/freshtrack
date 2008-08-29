require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe Time do
  it 'should be convertible to date' do
    Time.now.should respond_to(:to_date)
  end
  
  describe 'when converting to date' do
    before :each do
      @time = Time.now
      @date = @time.to_date
    end
    
    it 'should return a date' do
      @date.should be_kind_of(Date)
    end
    
    it 'should return an date with matching year' do
      @date.year.should == @time.year
    end
    
    it 'should return a date with matching month' do
      @date.month.should == @time.month
    end
    
    it 'should return a date with matching day' do
      @date.day.should == @time.day
    end
    
    it 'should return the same date for two times on the same day' do
      @time1 = Time.local(2008, 1, 25, 0, 0, 0)
      @time2 = Time.local(2008, 1, 25, 23, 59, 59)
      
      @time1.to_date.should == @time2.to_date
    end
  end
end
