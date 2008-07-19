require File.dirname(__FILE__) + '/../spec_helper'

describe "ResourceFull::Render", :type => :controller do
  controller_name :users
  
  describe "XML" do
    controller_name :users
    
    before :each do
      User.skip_validation = true
      User.delete_all
      UsersController.resource_identifier = :id
    end
  
    it "renders the model object" do
      user = User.create!
      get :show, :id => user.id, :format => 'xml'
      response.body.should have_tag("user")
      response.code.should == '200'
    end
    
    it "renders the appropriate error message if it can't find the model object" do
      get :show, :id => 1, :format => 'xml'
      response.body.should have_tag("errors") { with_tag("error", "ActiveRecord::RecordNotFound: not found: 1") }
      response.code.should == '404'
    end
    
    it "renders all model objects" do
      2.times { User.create! }
      get :index, :format => 'xml'
      Hash.from_xml(response.body)['users'].size.should == 2
      response.code.should == '200'
    end
    
    it "creates and renders a new model object with an empty body" do
      put :create, :user => { 'first_name' => 'brian' }, :format => 'xml'
      response.body.strip.should be_empty
      User.find(:first).first_name.should == 'brian'
    end
    
    it "creates a new model object and returns a status code of 201 (created)" do
      put :create, :user => { 'first_name' => 'brian' }, :format => 'xml'
      response.code.should == '201'
    end
    
    it "creates a new model object and places the location of the new object in the Location header" do
      put :create, :user => {}, :format => 'xml'
      response.headers['Location'].should == user_url(User.find(:first))
    end
    
    it "renders appropriate errors if a model validation fails" do
      User.validates_presence_of :first_name, :unless => :skip_validation?
      User.skip_validation = false
      put :create, :user => {}, :format => 'xml'
      response.should have_tag("errors") { with_tag("error", "First name can't be blank")}
    end
    
    class SomeNonsenseException < Exception; end
    
    it "rescues all unhandled exceptions with an XML response" do
      User.expects(:find).raises SomeNonsenseException, "sparrow farts"
      get :index, :format => 'xml'
      response.should have_tag("errors") { with_tag("error", "SomeNonsenseException: sparrow farts") }
    end
  end
end

