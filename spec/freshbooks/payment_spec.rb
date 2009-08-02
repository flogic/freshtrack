require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe FreshBooks::Payment do
  before :each do
    @payment = FreshBooks::Payment.new
  end
  
  describe 'attributes' do
    it 'should have an invoice_id' do
      @payment.should respond_to(:invoice_id)
    end
    
    it 'should have an amount' do
      @payment.should respond_to(:amount)
    end
  end
  
  describe 'type mappings' do
    before :each do
      @mapping = FreshBooks::Payment::TYPE_MAPPINGS
    end
    
    it 'should map amount to Float' do
      @mapping['amount'].should == Float
    end
  end
end
