require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

Thing     = FreshBooks::BaseObject.new(:attr)
ThingDeal = FreshBooks::BaseObject.new(:attr)

describe FreshBooks::BaseObject do
  it 'should have a mapping function for Date' do
    FreshBooks::BaseObject::MAPPING_FNS[Date].should.respond_to(:call)
  end
  
  describe 'Date mapping function' do
    before do
      @func = FreshBooks::BaseObject::MAPPING_FNS[Date]
      @date = mock('date arg', :text => '2008-01-29')
    end
    
    it 'should return a date' do
      @func.call(@date).should.be.kind_of(Date)
    end
    
    it 'should return a date matching the text of its argument' do
      @func.call(@date).to_s.should == @date.text
    end
  end

  it 'should have a mapping function for boolean' do
    FreshBooks::BaseObject::MAPPING_FNS[:boolean].should.respond_to(:call)
  end

  describe 'boolean mapping function' do
    before do
      @func = FreshBooks::BaseObject::MAPPING_FNS[:boolean]
    end

    it "should convert '0' to false" do
      @val  = mock('boolean arg', :text => '0')
      @func.call(@val).should == false
    end

    it "should convert '1' to true" do
      @val  = mock('boolean arg', :text => '1')
      @func.call(@val).should == true
    end
  end
  
  describe 'converting an instance to XML' do
    before do
      @thing = Thing.new
    end
    
    it 'should use the elem name' do
      @thing.should.receive(:elem_name)
      @thing.to_xml
    end
  end
  
  describe 'getting the elem name' do
    before do
      @thing = Thing.new
      @thing_deal = ThingDeal.new
    end
    
    it 'should be the class name, downcased' do
      @thing.elem_name.should == 'thing'
    end
    
    it 'should be underscored if the class name has CamelCase' do
      @thing_deal.elem_name.should == 'thing_deal'
    end
  end
end
