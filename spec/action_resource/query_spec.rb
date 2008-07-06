require File.dirname(__FILE__) + '/../spec_helper'

describe "ActionResource::Query", :type => :controller do
  controller_name "users"
  
  before :each do
    User.delete_all
    @users = [
      User.create!(:address_id => 1, :income => 70_000, :first_name => "guybrush"),
      User.create!(:address_id => 1, :income => 30_000, :first_name => "toothbrush"),
      User.create!(:address_id => 2, :income => 70_000, :first_name => "guthrie"),
    ]
  end
  attr_reader :users
  
  it "isn't queryable on any parameters by default" do
    UsersController.queryable_with
    controller.class.queryable_params.should be_empty
  end
  
  it "allows you to specify queryable parameters" do
    controller.class.queryable_with :address_id, :income
    controller.class.queryable_params.collect(&:name).should include(:address_id, :income)
  end
  
  it "retrieves objects based on a queried condition" do
    controller.class.queryable_with :address_id
    get :index, :address_id => 1
    assigns(:users).should include(users[0], users[1])
    assigns(:users).should_not include(users[2])
  end
  
  it "retrieves no objects if the queried condition is not matched" do
    controller.class.queryable_with :address_id
    get :index, :address_id => 3
    assigns(:users).should be_empty
  end
  
  it "queries on the intersection of multiple conditions" do
    controller.class.queryable_with :address_id, :income
    get :index, :address_id => 1, :income => 70_000
    assigns(:users).should == [ users[0] ]
  end
  
  it "queries multiple values in a comma-separated list" do
    controller.class.queryable_with :address_id, :income
    get :index, :address_id => "1,2"
    assigns(:users).should include(*users)
  end
  
  it "retrieves objects given pluralized forms of queryable parameters" do
    controller.class.queryable_with :address_id
    get :index, :address_ids => "1,2"
    assigns(:users).should include(*users)
  end
  
  it "uses LIKE clauses to query if the fuzzy option is specified" do
    controller.class.queryable_with :first_name, :fuzzy => true
    get :index, :first_name => "gu"
    assigns(:users).should include(users[0], users[2])
    assigns(:users).should_not include(users[1])
  end
  
  it "inherits queryable settings from its superclass"
  
end