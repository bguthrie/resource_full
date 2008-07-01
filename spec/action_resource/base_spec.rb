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
    controller.class.exposes(:fake)
    controller.model_class.should == Fake
  end
  
  it "exposes a particular resource model given a class" do
    controller.class.exposes Fake
    controller.model_class.should == Fake
  end
  
  it "renders two formats by default" do
    controller.class.renderable_formats.should include(:xml, :html)
  end
  
  it "allows you to specify what formats to render" do
    controller.class.responds_to :xml, :json
    controller.class.renderable_formats.should include(:xml, :json)
    controller.class.renderable_formats.should_not include(:html)
  end
  
  it "nests itself within another controller"
  it "disables sessions if the request format is XML or JSON"
end