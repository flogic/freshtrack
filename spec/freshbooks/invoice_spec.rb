require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe FreshBooks::Invoice do
  before do
    @invoice = FreshBooks::Invoice.new
  end
  
  describe 'attributes' do
    it 'should have an invoice_id' do
      @invoice.should.respond_to(:invoice_id)
    end
    
    it 'should have a client_id' do
      @invoice.should.respond_to(:client_id)
    end
    
    it 'should have a date' do
      @invoice.should.respond_to(:date)
    end
    
    it 'should have a status' do
      @invoice.should.respond_to(:status)
    end
    
    it 'should have an amount' do
      @invoice.should.respond_to(:amount)
    end
  end
  
  describe 'type mappings' do
    before do
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
    @invoice.should.respond_to(:open?)
  end
  
  describe 'indicating open status' do
    it "should be false if the status is 'draft'" do
      @invoice.status = 'draft'
      @invoice.should.not.be.open
    end
    
    it "should be true if the status is 'sent'" do
      @invoice.status = 'sent'
      @invoice.should.be.open
    end
    
    it "should be true if the status is 'viewed'" do
      @invoice.status = 'viewed'
      @invoice.should.be.open
    end
    
    it "should be false if the status is 'paid'" do
      @invoice.status = 'paid'
      @invoice.should.not.be.open
    end
    
    it "should be true if the status is 'partial'" do
      @invoice.status = 'partial'
      @invoice.should.be.open
    end
  end
  
  it 'should have a client' do
    @invoice.should.respond_to(:client)
  end
  
  describe 'client' do
    it 'should find client based on client_id' do
      client_id = mock('client ID')
      @invoice.stub!(:client_id).and_return(client_id)
      FreshBooks::Client.should.receive(:get).with(client_id)
      @invoice.client
    end
    
    it 'should return found client' do
      client = mock('client')
      client_id = mock('client ID')
      @invoice.stub!(:client_id).and_return(client_id)
      FreshBooks::Client.should.receive(:get).with(client_id).and_return(client)
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
      FreshBooks::Invoice.members.should.include('number')
    end
  end
  
  it 'should still have important core behavior' do
    FreshBooks::Invoice.should.respond_to(:list)
  end
  
  it 'should still be a type of BaseObject' do
    FreshBooks::Invoice.should < FreshBooks::BaseObject
  end
  
  it 'should still have other fields in the members list' do
    members = FreshBooks::Invoice.members
    members.should.include('invoice_id')
    members.should.include('client_id')
    members.should.include('status')
    members.should.include('date')
  end
  
  it 'should still allow other fields to be set and get using []' do
    @invoice['status'] = 'paid'
    @invoice.status.should == 'paid'
    
    @invoice.client_id = 3
    @invoice['client_id'].should == 3
  end
  
  it 'should have payments' do
    @invoice.should.respond_to(:payments)
  end
  
  describe 'payments' do
    before do
      @payments = Array.new(3) { mock('payment') }
      FreshBooks::Payment.stub!(:list).and_return(@payments)
    end
    
    it 'should get a list from Payment' do
      FreshBooks::Payment.should.receive(:list)
      @invoice.payments
    end
    
    it 'should pass the invoice_id when getting the list' do
      @invoice.invoice_id = '0000073'
      FreshBooks::Payment.should.receive(:list).with('invoice_id' => @invoice.invoice_id)
      @invoice.payments
    end
    
    it 'should return the list from Payment' do
      @invoice.payments.should == @payments
    end
    
    it 'should return an empty array if Payment returns nil' do
      FreshBooks::Payment.stub!(:list).and_return(nil)
      @invoice.payments.should == []
    end
  end
  
  it 'should have a paid amount' do
    @invoice.should.respond_to(:paid_amount)
  end
  
  describe 'paid amount' do
    it 'should be the sum of payment amounts' do
      payments = [mock('payment', :amount => 3), mock('payment', :amount => 15), mock('payment', :amount => 5)]
      @invoice.stub!(:payments).and_return(payments)
      @invoice.paid_amount.should == 23
    end
    
    it 'should be 0 if there are no payments' do
      @invoice.stub!(:payments).and_return([])
      @invoice.paid_amount.should == 0
    end
  end
  
  it 'should have an owed amount' do
    @invoice.should.respond_to(:owed_amount)
  end
  
  describe 'owed amount' do
    it 'should be invoice amount less paid amount' do
      @invoice.amount = 60
      @invoice.stub!(:paid_amount).and_return(50)
      @invoice.owed_amount.should == 10
    end
  end
end
