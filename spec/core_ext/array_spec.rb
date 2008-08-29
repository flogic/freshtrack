require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe Array do
  it 'should be groupable' do
    Array.new.should respond_to(:group_by)
  end
  
  describe 'when grouping' do
    before :each do
      @array = (1..10).to_a
    end
    
    it 'should require a block' do
      lambda { @array.group_by }.should raise_error(ArgumentError)
    end
    
    it 'should accept a block' do
      lambda { @array.group_by {} }.should_not raise_error(ArgumentError)
    end
    
    it 'should return a hash' do
      @array.group_by {}.should be_kind_of(Hash)
    end
    
    it 'should group the elements by the return value of the block' do
      [1,2,3,4,5,6,7,8,9,10]
      expected = {
        0 => [3,6,9],
        1 => [1,4,7,10],
        2 => [2,5,8]
      }
      @array.group_by { |x|  x % 3 }.should == expected
    end
  end
end
