require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe FreshBooks::Invoice do
  before :each do
    @invoice = FreshBooks::Invoice.new
  end
  
  describe 'attributes' do
    it 'should have an invoice_id' do
      @invoice.should respond_to(:invoice_id)
    end
    
    it 'should have a client_id' do
      @invoice.should respond_to(:client_id)
    end
    
    it 'should have a date' do
      @invoice.should respond_to(:date)
    end
    
    it 'should have a status' do
      @invoice.should respond_to(:status)
    end
  end
  
  describe 'type mappings' do
    before :each do
      @mapping = FreshBooks::Invoice::TYPE_MAPPINGS
    end
    
    it 'should map client_id to Fixnum' do
      @mapping['client_id'].should == Fixnum
    end
    
    it 'should map date to Date' do
      @mapping['date'].should == Date
    end
  end
  
  it 'should indicate open status' do
    @invoice.should respond_to(:open?)
  end
  
  describe 'indicating open status' do
    it "should be false if the status is 'draft'" do
      @invoice.status = 'draft'
      @invoice.should_not be_open
    end
    
    it "should be true if the status is 'sent'" do
      @invoice.status = 'sent'
      @invoice.should be_open
    end
    
    it "should be true if the status is 'viewed'" do
      @invoice.status = 'viewed'
      @invoice.should be_open
    end
    
    it "should be false if the status is 'paid'" do
      @invoice.status = 'paid'
      @invoice.should_not be_open
    end
    
    it "should be true if the status is 'partial'" do
      @invoice.status = 'partial'
      @invoice.should be_open
    end
  end
end
