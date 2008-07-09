require File.dirname(__FILE__) + '/../spec_helper'

describe "ActionResource::Retrieve", :type => :controller do
  controller_name "users"
  
  before :each do
    User.delete_all
    UsersController.resource_identifier = :id
  end
  
  it "defines custom methods based on the class name" do
    controller.should respond_to(
      :find_user, 
      :find_all_users, 
      :update_user, 
      :destroy_user, 
      :new_user
    )
  end
  
  def params; @params ||= {}; end
  
  it "finds the requested model object" do
    user = User.create!
    get :show, :id => user.id
    assigns(:user).should == user
  end
  
  it "finds the requested model object using the correct column if the resource_identifier attribute has been overridden" do
    UsersController.resource_identifier = :first_name
    User.create! :first_name => "eustace"
    get :show, :id => "eustace"
    assigns(:user).first_name.should == "eustace"
  end
  
  it "updates the requested model object based on the given parameters" do
    user = User.create! :last_name => "threepwood"
    post :update, :id => user.id, :user => { :last_name => "guybrush" }
    user.reload.last_name.should == "guybrush"
  end
  
  it "updates the requested model object using the correct column if the resource_identifier attribute has been overridden" do
    UsersController.resource_identifier = :first_name
    user = User.create! :first_name => "guybrush"
    post :update, :id => "guybrush", :user => { :last_name => "threepwood" }
    user.reload.last_name.should == "threepwood"
  end
  
  it "creates a new model object based on the given parameters" do
    put :create, :user => { :first_name => "guybrush", :last_name => "threepwood" }
    User.count.should == 1
    User.find(:first).first_name.should == "guybrush"
  end
  
  it "creates a new model object appropriately if a creational parameter is queryable but not placed in the model object params, as with a nested route" do
    UsersController.queryable_with :first_name
    put :create, :first_name => "guybrush", :user => { :last_name => "threepwood" }
    User.count.should == 1
    user = User.find :first
    user.first_name.should == "guybrush"
    user.last_name.should == "threepwood"
  end
  
  it "deletes the requested model object" do
    user = User.create!
    delete :destroy, :id => user.id
    User.exists?(user.id).should be_false
  end
  
  it "deletes the requested model object using the correct column if the resource_identifier attribute has been overridden" do
    UsersController.resource_identifier = :first_name
    user = User.create! :first_name => "guybrush"
    delete :destroy, :id => "guybrush"
    User.exists?(user.id).should be_false
  end
  
  describe "with pagination" do
    controller_name :users
    
    before :each do
      User.delete_all
      @users = (1..6).collect { User.create! }
    end
    
    after :all do
      User.delete_all
    end
    
    it "limits the query to the correct number of records given that parameter" do
      get :index, :limit => 2
      assigns(:users).should == @users[0..1]
    end
    
    it "offsets the query by the correct number of records" do
      get :index, :offset => 4, :limit => 2
      assigns(:users).should == @users[4..5]
    end
    
    it "doesn't attempt to paginate if pagination is disabled" do
      UsersController.paginatable = false
      get :index, :offset => 4, :limit => 2
      assigns(:users).should == @users
      UsersController.paginatable = true # cleanup
    end
  end
  
end