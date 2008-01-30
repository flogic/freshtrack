require File.dirname(__FILE__) + '/spec_helper.rb'

describe FreshBooks::BaseObject do
  it 'should have a mapping function for Date' do
    FreshBooks::BaseObject::MAPPING_FNS[Date].should respond_to(:call)
  end
  
  describe 'Date mapping function' do
    before :each do
      @func = FreshBooks::BaseObject::MAPPING_FNS[Date]
      @date = stub('date arg', :text => '2008-01-29')
    end
    
    it 'should return a date' do
      @func.call(@date).should be_kind_of(Date)
    end
    
    it 'should return a date matching the text of its argument' do
      @func.call(@date).to_s.should == @date.text
    end
  end
end
