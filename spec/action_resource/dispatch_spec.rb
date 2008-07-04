require File.dirname(__FILE__) + '/../spec_helper'

describe ActionResource::Dispatch, :type => :controller do
  controller_name "mocks"
  
  before(:each) do
    Mock.stubs(:find).returns(:id => 1)
    MocksController.responds_to :html, :xml
  end
  
  it "defines methods based on the five core REST methods" do
    controller.methods.should include("index", "create", "update", "show", "destroy")
  end
  
  it "dispatches to index_xml render method if xml is requested" do
    controller.expects(:index_xml)
    get :index, :format => 'xml'
  end
  
  it "dispatches to index_html render method if html is requested" do  
    controller.expects(:index_html)
    get :index, :format => 'html'
  end
  
  it "raises a 406 error if it does not respond to a particular format" do
    get :index, :format => 'json'
    response.code.should == '406'
  end
  
  describe "GET index" do
    controller_name :mocks
    
    it "sets an @mocks instance variable based on the default finder" do
      Mock.stubs(:find).returns "a list of mocks"
      get :index
      assigns(:mocks).should == "a list of mocks"
    end
    
    it "sets an @mocks instance variable appropriately if the default finder is overridden" do
      MocksController.class_eval do
        def find_all_mocks; "another list of mocks"; end
      end      
      get :index
      assigns(:mocks).should == "another list of mocks"
    end    
  end
  
  describe "GET show" do
    controller_name :mocks
    
    it "sets a @mock instance variable based on the default finder" do
      Mock.stubs(:find).returns "a mock"
      get :show, :id => 1
      assigns(:mock).should == "a mock"
    end
    
    it "sets a @mock instance variable appropriately if the default finder is overridden" do
      MocksController.class_eval do
        def find_mock; "another mock"; end
      end
      get :show, :id => 1
      assigns(:mock).should == "another mock"
    end
  end
  
  describe "POST create" do
    controller_name :mocks
    
    it "sets a @mock instance variable based on the default creator" do
      Mock.stubs(:create).returns stub(:valid? => true, :id => :mock)
      post :create
      assigns(:mock).id.should == :mock
    end
    
    it "sets a @mock instance variable appropriately if the default creator is overridden" do
      Mock.stubs(:super_create).returns stub(:valid? => true, :id => :super_mock)
      MocksController.class_eval do
        def create_mock; Mock.super_create; end
      end
      post :create
      assigns(:mock).id.should == :super_mock
    end
  end
  
  describe "PUT update" do
    controller_name :mocks
    
    it "sets a @mock instance variable based on the default updater" do
      Mock.stubs(:update).returns stub(:valid? => true, :id => :mock)
      put :update, :id => 1
      assigns(:mock).id.should == :mock
    end
    
    it "sets a @mock instance variable appropriately if the default updater is overridden" do
      Mock.stubs(:super_update).returns stub(:valid? => true, :id => :super_mock)
      MocksController.class_eval do
        def update_mock; Mock.super_update; end
      end
      put :update, :id => 1
      assigns(:mock).id.should == :super_mock
    end
  end  
end