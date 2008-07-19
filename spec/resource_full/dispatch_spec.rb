require File.dirname(__FILE__) + '/../spec_helper'

class OverridableMocksController < ApplicationController
  exposes :mocks
end

describe "ResourceFull::Dispatch", :type => :controller do
  controller_name :mocks
  
  before(:each) do
    Mock.stubs(:find).returns stub(:id => 1)
  end
  
  describe "based on request format" do
    controller_name :mocks
    
    after :each do
      controller.class.responds_to :defaults
    end
  
    it "dispatches to index_xml render method if xml is requested" do
      controller.expects(:index_xml)
      get :index, :format => 'xml'
    end
  
    it "dispatches to index_html render method if html is requested" do  
      controller.expects(:index_html)
      get :index, :format => 'html'
    end
  
    it "raises a 406 error if it does not respond to a format for which no methods are included" do
      get :index, :format => 'json'
      response.code.should == '406'
    end
  
    it "raises a 406 error if it does not respond to a format which has been explicitly removed" do
      controller.class.responds_to :xml
      get :index, :format => 'html'
      response.code.should == '406'
    end
    
    it "includes an appropriate error message if it does not respond to a format which has been explicitly removed" do
      controller.class.responds_to :xml
      get :index, :format => 'html'
      response.body.should =~ /Resource does not have a representation in text\/html format/
    end
  end
  
  describe "based on request action" do
    controller_name :mocks
    
    after :each do
      controller.class.responds_to :defaults
    end
    
    it "claims to respond to create, read, update, delete, and count by default" do
      controller.class.responds_to :defaults
      controller.class.allowed_methods.should include(:create, :read, :update, :delete)
    end
    
    it "claims to not respond to any methods for an unsupported format" do
      controller.class.responds_to :xml
      controller.class.allowed_methods(:html).should be_empty
    end
    
    it "claims to respond to default methods for a requested format if no explicit methods are given" do
      controller.class.responds_to :xml
      controller.class.allowed_methods(:xml).should include(:create, :read, :update, :delete)
    end
    
    it "claims to respond to only methods given a single value with the :only option" do
      controller.class.responds_to :xml, :only => :read
      controller.class.allowed_methods(:xml).should == [:read]
    end
    
    it "claims to respond to only methods given multiple values with the :only option" do
      controller.class.responds_to :xml, :only => [:read, :delete]
      controller.class.allowed_methods(:xml).should == [:read, :delete]
    end
    
    it "responds successfully to supported methods" do
      controller.class.responds_to :xml, :only => :read
      controller.stubs(:index)
      get :index, :format => "xml"
      response.should be_success
    end
    
    it "disallows unsupported methods with code 405" do
      controller.class.responds_to :html, :only => :read
      controller.stubs(:destroy)
      delete :destroy, :id => 1
      response.code.should == '405'
      response.body.should =~ /Resource does not allow destroy action/
    end
  end
  
  describe "GET index" do
    controller_name :mocks
    
    it "sets an @mocks instance variable based on the default finder" do
      Mock.stubs(:find).returns "a list of mocks"
      get :index, :format => 'html'
      assigns(:mocks).should == "a list of mocks"
    end
    
    it "sets an @mocks instance variable appropriately if the default finder is overridden" do
      controller.class.class_eval do
        def find_all_mocks; "another list of mocks"; end
      end      
      get :index, :format => 'html'
      assigns(:mocks).should == "another list of mocks"
    end    
  end
  
  describe "GET show" do
    controller_name :mocks
    
    it "sets a @mock instance variable based on the default finder" do
      Mock.stubs(:find).returns "a mock"
      get :show, :id => 1, :format => 'html'
      assigns(:mock).should == "a mock"
    end
    
    it "sets a @mock instance variable appropriately if the default finder is overridden" do
      controller.class.class_eval do
        def find_mock; "another mock"; end
      end
      get :show, :id => 1, :format => 'html'
      assigns(:mock).should == "another mock"
    end
  end
  
  describe "POST create" do
    controller_name :mocks
    
    it "sets a @mock instance variable based on the default creator" do
      Mock.stubs(:create).returns stub(:valid? => true, :id => :mock)
      post :create, :format => 'html'
      assigns(:mock).id.should == :mock
    end
    
    it "sets a @mock instance variable appropriately if the default creator is overridden" do
      Mock.stubs(:super_create).returns stub(:valid? => true, :id => :super_mock)
      controller.class.class_eval do
        def create_mock; Mock.super_create; end
      end
      post :create, :format => 'html'
      assigns(:mock).id.should == :super_mock
    end
  end
  
  describe "PUT update" do
    controller_name :mocks
    
    it "sets a @mock instance variable based on the default updater" do
      Mock.stubs(:find).returns stub(:id => 1, :update_attributes => true, :valid? => true)
      put :update, :id => 1, :format => 'html'
      assigns(:mock).id.should == 1
    end
    
    it "sets a @mock instance variable appropriately if the default updater is overridden" do
      Mock.stubs(:super_update).returns stub(:valid? => true, :id => :super_mock)
      controller.class.class_eval do
        def update_mock; Mock.super_update; end
      end
      put :update, :id => 1, :format => 'html'
      assigns(:mock).id.should == :super_mock
    end
  end  
end