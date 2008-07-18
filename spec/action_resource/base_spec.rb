require File.dirname(__FILE__) + '/../spec_helper'

describe ActionResource::Base, :type => :controller do
  controller_name "mocks"

  it "infers the name of its resource model from its class name" do
    controller.model_name.should == "mock"
  end
  
  it "infers the class of its resource model from its class name" do
    controller.model_class.should == Mock
  end
  
  class Fake; end
  
  it "exposes a particular resource model given a symbol" do
    controller.class.exposes :fake
    controller.model_class.should == Fake
    controller.class.exposes :mock # cleanup
  end
  
  it "exposes a particular resource model given a pluralized symbol" do
    controller.class.exposes :fakes
    controller.model_class.should == Fake
    controller.class.exposes :mock # cleanup
  end
  
  it "exposes a particular resource model given a class" do
    controller.class.exposes Fake
    controller.model_class.should == Fake
    controller.class.exposes Mock # cleanup
  end
  
  it "renders two formats by default" do
    controller.class.allowed_formats.should include(:xml, :html)
  end
  
  it "allows you to specify what formats to render" do
    controller.class.responds_to :xml, :json
    controller.class.allowed_formats.should include(:xml, :json)
    controller.class.allowed_formats.should_not include(:html)
  end
  
  it "disables sessions if the request format is XML or JSON"
  it "plays nicely with subclasses and attributes"
  
  class NonResourcesController < ActionController::Base; end
  class ResourcesController    < ActionResource::Base; end
  
  it "knows about all controller subclasses of itself" do
    ActionController::Routing.expects(:possible_controllers).at_least_once.returns %w{resources non_resources}
    ActionResource::Base.all_resources.should include(ResourcesController)
    ActionResource::Base.all_resources.should_not include(NonResourcesController)
  end
  
  it "serializes the notion of a resource controller as XML" do
    UsersController.queryable_with :first_name
    xml = Hash.from_xml(UsersController.to_xml)
    xml["resource"]["name"].should == "user"
    xml["resource"]["parameters"].first["name"].should == "first_name"
  end
  
  it "has a default value of :id for the resource identifier column" do
    UsersController.resource_identifier.should == :id
  end
  
  it "allows you to set the resource_identifier field" do
    controller.class.resource_identifier = :first_name
    controller.class.resource_identifier.should == :first_name
    controller.class.resource_identifier = :id # cleanup
  end
  
  it "is paginatable by default" do
    controller.class.should be_paginatable
  end
end