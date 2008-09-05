require File.dirname(__FILE__) + '/../../spec_helper'

# TODO Most of this functionality is covered by more functional tests elsewhere,
# but it would be nice to have better unit-level coverage for specific breakages.
describe ResourceFull::Query::Parameter do
  it "renders itself as XML" do
    xml = ResourceFull::Query::Parameter.new(
      :name, 
      mock(:model_name => "user"), 
      :fuzzy => true, 
      :columns => [:full_name, :username, :email]
    ).to_xml
    
    xml.should have_tag("parameter") do
      with_tag("fuzzy", "true")
      with_tag("name", "name")
      with_tag("from", "user")
      with_tag("columns", "full_name,username,email")
    end
  end
  
  describe "subclass" do
    it "returns a copy of itself with the given resource" do
      ResourceFull::Query::Parameter.new(:name, ResourceFullMocksController).subclass(ResourceFullSubMocksController).from.should == "resource_full_sub_mock"
    end
  end
  
end
