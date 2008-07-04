require File.dirname(__FILE__) + '/../spec_helper'

describe "ActionResource::Retrieve", :type => :controller do
  controller_name "users"
  
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
    User.expects(:find).with(:first, :conditions => {:first_name => "eustace"})
    get :show, :id => "eustace"
    UsersController.resource_identifier = :id
  end
  
  it "updates the requested model object based on the given parameters" do
    user = User.create! :last_name => "guthrie"
    post :update, :id => user.id, :user => { :last_name => "guybrush" }
    user.reload.last_name.should == "guybrush"
  end
  
end