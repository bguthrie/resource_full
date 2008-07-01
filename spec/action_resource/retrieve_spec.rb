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
  
  it "finds the given user" do
    user = User.create!
    get :show, :id => user.id
    assigns(:user).should == user
  end
  
end