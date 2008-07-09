require File.dirname(__FILE__) + '/../../spec_helper'

# TODO Most of this functionality is covered by more functional tests elsewhere,
# but it would be nice to have better unit-level coverage for specific breakages.
describe ActionResource::Query::Parameter do
  it "renders itself as XML" do
    xml = ActionResource::Query::Parameter.new(
      :name, 
      mock(:model_name => "user", :model_class => mock(:table_name => "users")), 
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
end
