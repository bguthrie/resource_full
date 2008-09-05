require File.dirname(__FILE__) + '/../spec_helper'

describe "ResourceFull::Query", :type => :controller do
  controller_name "resource_full_mock_users"
  
  before :all do
    ResourceFullMockUser.delete_all
    @users = [
      ResourceFullMockUser.create!(:address_id => 1, :income => 70_000, :first_name => "guybrush"),
      ResourceFullMockUser.create!(:address_id => 1, :income => 30_000, :first_name => "toothbrush"),
      ResourceFullMockUser.create!(:address_id => 2, :income => 70_000, :first_name => "guthrie"),
    ]
  end
  attr_reader :users
  
  before :each do
    ResourceFullMockUsersController.queryable_params = nil
  end
  
  it "allows you to specify a method that filters the returned list"
  
  it "isn't queryable on any parameters by default" do
    controller.class.queryable_params.should be_empty
  end
  
  it "allows you to specify queryable parameters" do
    controller.class.queryable_with :address_id, :income
    controller.class.queryable_params.collect(&:name).should include(:address_id, :income)
  end
  
  it "retrieves objects based on a queried condition" do
    controller.class.queryable_with :address_id
    get :index, :address_id => 1
    assigns(:resource_full_mock_users).should include(users[0], users[1])
    assigns(:resource_full_mock_users).should_not include(users[2])
  end
  
  it "retrieves no objects if the queried condition is not matched" do
    controller.class.queryable_with :address_id
    get :index, :address_id => 3
    assigns(:resource_full_mock_users).should be_empty
  end
  
  it "queries on the intersection of multiple conditions" do
    controller.class.queryable_with :address_id, :income
    get :index, :address_id => 1, :income => 70_000
    assigns(:resource_full_mock_users).should == [ users[0] ]
  end
  
  it "queries multiple values in a comma-separated list" do
    controller.class.queryable_with :address_id, :income
    get :index, :address_id => "1,2"
    assigns(:resource_full_mock_users).should include(*users)
  end
  
  it "retrieves objects given pluralized forms of queryable parameters" do
    controller.class.queryable_with :address_id
    get :index, :address_ids => "1,2"
    assigns(:resource_full_mock_users).should include(*users)
  end
  
  it "uses LIKE clauses to query if the fuzzy option is specified" do
    controller.class.queryable_with :first_name, :fuzzy => true
    get :index, :first_name => "gu"
    assigns(:resource_full_mock_users).should include(users[0], users[2])
    assigns(:resource_full_mock_users).should_not include(users[1])
  end
  
  it "allows a queryable parameter to map to a different column" do
    controller.class.queryable_with :address, :column => :address_id
    get :index, :address => 1
    assigns(:resource_full_mock_users).should include(users[0], users[1])
    assigns(:resource_full_mock_users).should_not include(users[2])
  end
  
  it "appends to rather than replaces queryable values" do
    controller.class.queryable_with :address_id
    controller.class.queryable_with :income
    
    get :index, :address_id => 1, :income => 70_000
    assigns(:resource_full_mock_users).should include(users[0])
    assigns(:resource_full_mock_users).should_not include(users[1], users[2])
  end
  
  it "counts all objects if there are no parameters" do
    controller.class.queryable_with :address_id
    get :count
    Hash.from_xml(response.body)['count'].to_i.should == 3
  end
  
  it "counts the requested objects if there are paramters" do
    controller.class.queryable_with :address_id
    get :count, :address_id => 1
    Hash.from_xml(response.body)['count'].to_i.should == 2
  end

  it "counts no objects if there are none with the requested parameters" do
    controller.class.queryable_with :address_id
    get :count, :address_id => 15
    Hash.from_xml(response.body)['count'].to_i.should == 0
  end
  
  describe "with multiple columns" do
    controller_name "resource_full_mock_users"
    
    before :all do
      ResourceFullMockUser.delete_all
      @users = [
        ResourceFullMockUser.create!(:first_name => "guybrush", :last_name => "threepwood"),
        ResourceFullMockUser.create!(:first_name => "herman",   :last_name => "guybrush"),
        ResourceFullMockUser.create!(:first_name => "ghost_pirate", :last_name => "le_chuck")
      ]
    end
    attr_reader :users
    
    before :each do
      ResourceFullMockUsersController.queryable_params = nil
    end
  
    it "allows a queryable parameter to map to multiple columns" do    
      controller.class.queryable_with :name, :columns => [:first_name, :last_name]
      get :index, :name => "guybrush"
      assigns(:resource_full_mock_users).should include(users[0], users[1])
      assigns(:resource_full_mock_users).should_not include(users[2])
    end
  
    it "queries fuzzy values across multiple columns" do
      controller.class.queryable_with :name, :columns => [:first_name, :last_name], :fuzzy => true
      get :index, :name => "gu"
      assigns(:resource_full_mock_users).should include(users[0], users[1])
      assigns(:resource_full_mock_users).should_not include(users[2])
    end
  end
  
  describe "with joins" do
    controller_name "resource_full_mock_addresses"
    
    before :each do
      ResourceFullMockUser.delete_all
      ResourceFullMockAddress.delete_all
      
      @user = ResourceFullMockUser.create! :email => "gthreepwood@melee.gov"
      @valid_addresses = [
        @user.resource_full_mock_addresses.create!,
        @user.resource_full_mock_addresses.create!
      ]
      
      invalid_user = ResourceFullMockUser.create! :email => "blah@blah.com"
      @invalid_address = invalid_user.resource_full_mock_addresses.create!
      
      ResourceFullMockUsersController.resource_identifier = :id
      ResourceFullMockAddressesController.queryable_params = nil
    end
    attr_reader :user, :valid_addresses, :invalid_address
    
    it "filters addresses by the appropriate column and join if a :from relationship is defined" do
      ResourceFullMockAddressesController.queryable_with :email, :from => :resource_full_mock_user
      
      get :index, :resource_full_mock_user_id => 'foo', :email => user.email
      assigns(:resource_full_mock_addresses).should include(*valid_addresses)
      assigns(:resource_full_mock_addresses).should_not include(invalid_address)
    end
    
    it "filters addresses by the User resource identifier if a :from is specified along with :resource_identifier" do
      ResourceFullMockUsersController.resource_identifier = :email
      ResourceFullMockAddressesController.queryable_with :resource_full_mock_user_id, :from => :resource_full_mock_user, :resource_identifier => true
            
      get :index, :resource_full_mock_user_id => user.email
      assigns(:resource_full_mock_addresses).should include(*valid_addresses)
      assigns(:resource_full_mock_addresses).should_not include(invalid_address)
    end
    
    # TODO This is perhaps not the best place for this test.  
    it "filters addresses by the User resource identifer if a controller is said to nest within another controller" do
      ResourceFullMockUsersController.resource_identifier = :email
      ResourceFullMockAddressesController.nests_within(:resource_full_mock_user)
      
      get :index, :resource_full_mock_user_id => user.email
      assigns(:resource_full_mock_addresses).should include(*valid_addresses)
      assigns(:resource_full_mock_addresses).should_not include(invalid_address)
    end
  end
  
  describe "with subclasses" do
    controller_name "resource_full_sub_mocks"
    before :each do
      ResourceFullMocksController.queryable_params    = nil
      ResourceFullSubMocksController.queryable_params = nil
    end
    
    it "allows subclasses to add to the list of queryable parameters" do
      ResourceFullMocksController.queryable_with :foo
      ResourceFullSubMocksController.queryable_with :bar
      ResourceFullSubMocksController.should be_queryable_with(:foo, :bar)      
    end
    
    it "doesn't alter the queryable parameters of a superclass when a subclass" do
      ResourceFullMocksController.queryable_with :foo
      ResourceFullSubMocksController.queryable_with :bar
      ResourceFullMocksController.should_not be_queryable_with(:bar)
    end
        
    it "uses the model and table name of the subclass rather than the superclass when querying" do
      ResourceFullMocksController.queryable_with :first_name
      ResourceFullSubMocksController.exposes :resource_full_mock_users
      ResourceFullMockUser.create! :first_name => "guybrush"
      ResourceFullMock.expects(:find).never
      get :index, :format => 'xml', :first_name => 'guybrush'
      response.body.should have_tag("resource-full-mock-user") { with_tag("first-name", "guybrush") }
    end
    
  end
end