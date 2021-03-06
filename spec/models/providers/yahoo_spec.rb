require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Contacts::Provider::Yahoo do
  
  def klass
    @klass ||= Contacts::Provider::Yahoo
  end
  
  def instance attrs={}
    @instance ||= klass.new(attrs)
  end
  
  def valid_attributes
    {:consumer_key => 'anonymous', :consumer_secret => 'anonymous', :token => 'ACCESS-TOKEN', :secret => 'ACCESS-SECRET'}
  end

  it "should have an provider id of 'yahoo'" do
    klass.provider_id.should == 'yahoo'
  end
  
  it "should extend the OAuth provider" do
    klass.superclass.should == Contacts::Provider::OAuth
  end
  
  context "valid_attributes" do
    it_should_include :consumer_key
    it_should_include :consumer_secret 
    it_should_include :token
    it_should_include :secret
  end
  
  context "when initialized" do
    before { instance valid_attributes }
                         
    it_should_respond_to :consumer_key
    it_should_respond_to :consumer_secret
    it_should_respond_to :token
    it_should_respond_to :secret
    it_should_respond_to :uid
    it_should_respond_to :site_url
    
    it "should not raise error when initializing connection" do
      lambda { instance.connection }.should_not raise_error
    end
    
    it "should set up the connection" do
      instance.connection.should be_kind_of(OAuth::AccessToken)
    end
    
    it "should have site_url set to 'http://social.yahooapis.com'" do
      instance.site_url.should == 'http://social.yahooapis.com'
    end
    
    context "when authorized" do
      before do
        @response = mock('Response')
        @response_body = File.read(File.expand_path(File.dirname(__FILE__) + '/../../files/providers/yahoo/valid_contacts')).to_s
        @response.stub(:body).and_return(@response_body)
        instance.connection.stub!(:get).with("/v1/user/me/contacts?format=json").and_return(@response)
      end                   
      
      it_should_respond_to :contacts
      it_should_respond_to :retrieve_contacts!
      it_should_respond_to :contacts_response  
      it_should_respond_to :parse_contacts! 
      
      it "should not raise error when returning contacts" do 
        lambda { instance.contacts }.should_not raise_error      
      end
      
      it "should not raise error when retrieving contacts" do 
        lambda { instance.retrieve_contacts! }.should_not raise_error      
      end
      
      it "should not raise error when parsing contacts" do
        instance.retrieve_contacts! 
        lambda { instance.parse_contacts! }.should_not raise_error      
      end
      
      it "should set contacts_response" do
        instance.retrieve_contacts! 
        instance.contacts_response.should be_present
        instance.contacts_response.should == @response
      end
      
      context "parsing contacts" do
        before { instance.retrieve_contacts! }
        
        it "should return an array of yahoo contacts" do
          instance.parse_contacts!
          instance.contacts.should be_kind_of(Array)
          instance.should have(2).contacts 
          first_contact = instance.contacts.first
          first_contact.should be_kind_of(Contacts::Contact::Yahoo)
        end
        
      end
      
    end
  
  end
       
end