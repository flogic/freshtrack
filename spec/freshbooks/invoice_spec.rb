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
    
    it 'should have an amount' do
      @invoice.should respond_to(:amount)
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
    
    it 'should map amount to Float' do
      @mapping['amount'].should == Float
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
  
  it 'should have a client' do
    @invoice.should respond_to(:client)
  end
  
  describe 'client' do
    it 'should find client based on client_id' do
      client_id = stub('client ID')
      @invoice.stubs(:client_id).returns(client_id)
      FreshBooks::Client.expects(:get).with(client_id)
      @invoice.client
    end
    
    it 'should return found client' do
      client = stub('client')
      client_id = stub('client ID')
      @invoice.stubs(:client_id).returns(client_id)
      FreshBooks::Client.expects(:get).with(client_id).returns(client)
      @invoice.client.should == client
    end
  end
  
  describe 'number' do
    it 'should be settable and gettable as an accessor' do
      @invoice.number = '1234'
      @invoice.number.should == '1234'
    end
    
    it 'should be settable using []' do
      @invoice['number'] = '1234'
      @invoice.number.should == '1234'
    end
    
    it 'should be gettable using []' do
      @invoice.number = '1234'
      @invoice['number'].should == '1234'
    end
    
    it 'should show up in the members list' do
      FreshBooks::Invoice.members.should include('number')
    end
  end
  
  it 'should still have important core behavior' do
    FreshBooks::Invoice.should respond_to(:list)
  end
  
  it 'should still be a type of BaseObject' do
    FreshBooks::Invoice.should < FreshBooks::BaseObject
  end
  
  it 'should still have other fields in the members list' do
    members = FreshBooks::Invoice.members
    members.should include('invoice_id')
    members.should include('client_id')
    members.should include('status')
    members.should include('date')
  end
  
  it 'should still allow other fields to be set and get using []' do
    @invoice['status'] = 'paid'
    @invoice.status.should == 'paid'
    
    @invoice.client_id = 3
    @invoice['client_id'].should == 3
  end
  
  it 'should have payments' do
    @invoice.should respond_to(:payments)
  end
  
  describe 'payments' do
    before :each do
      @payments = Array.new(3) { stub('payment') }
      FreshBooks::Payment.stubs(:list).returns(@payments)
    end
    
    it 'should get a list from Payment' do
      FreshBooks::Payment.expects(:list)
      @invoice.payments
    end
    
    it 'should pass the invoice_id when getting the list' do
      @invoice.invoice_id = '0000073'
      FreshBooks::Payment.expects(:list).with('invoice_id' => @invoice.invoice_id)
      @invoice.payments
    end
    
    it 'should return the list from Payment' do
      @invoice.payments.should == @payments
    end
    
    it 'should return an empty array if Payment returns nil' do
      FreshBooks::Payment.stubs(:list).returns(nil)
      @invoice.payments.should == []
    end
  end
end
