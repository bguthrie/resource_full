require File.dirname(__FILE__) + '/../spec_helper'

describe "ActionResource::Render", :type => :controller do
  controller_name :mocks
  
  describe "XML" do
    controller_name :mocks
  
    it "renders the model object" do
      Mock.expects(:find).returns mock(:to_xml => "a mock")
      get :show, :id => 1, :format => 'xml'
      response.body.should == 'a mock'
      response.code.should == '200'
    end
    
    it "renders the appropriate error message if it can't find the model object" do
      Mock.expects(:find).raises(ActiveRecord::RecordNotFound, "not found")
      get :show, :id => 1, :format => 'xml'
      response.body.should have_tag("errors") { with_tag("error", "ActiveRecord::RecordNotFound: not found") }
      response.code.should == '404'
    end
    
    it "renders all model objects" do
      Mock.expects(:find).with(:all, *anything).returns mock(:to_xml => "many mocks")
      get :index, :format => 'xml'
      response.body.should == 'many mocks'
      response.code.should == '200'
    end
    
    it "creates and renders a new model object with an empty body" do
      Mock.expects(:create).with('a' => 'b', 'c' => 'd').returns mock(:valid? => true, :id => 1)
      put :create, :mock => { 'a' => 'b', 'c' => 'd' }, :format => 'xml'
      response.body.strip.should be_empty
    end
    
    it "creates a new model object and returns a status code of 201 (created)" do
      Mock.expects(:create).returns mock(:valid? => true, :id => 1)
      put :create, :mock => {}, :format => 'xml'
      response.code.should == '201'
    end
    
    it "creates a new model object and places the location of the new object in the Location header" do
      Mock.expects(:create).returns mock(:valid? => true, :id => 1)
      put :create, :mock => {}, :format => 'xml'
      response.headers['Location'].should == mock_url(1)
    end
    
    class SomeNonsenseException < Exception; end
    
    it "rescues all unhandled exceptions with an XML response" do
      Mock.expects(:find).raises SomeNonsenseException, "sparrow farts"
      get :index, :format => 'xml'
      response.should have_tag("errors") { with_tag("error", "SomeNonsenseException: sparrow farts") }
    end
  end
end

