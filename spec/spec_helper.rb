# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + '/../../../../config/environment')  
require 'spec'
require 'spec/rails'
require 'resource_full/core_extensions/from_json'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/vendor/plugins/resource_full/spec/fixtures/'
  config.mock_with :mocha
  
  config.before(:all) do
    ActiveRecord::Base.connection.create_table "resource_full_mock_addresses", :force => true do |t|
      t.string   "street"
      t.string   "city"
      t.string   "state_code"
      t.integer  "zip"
      t.integer  "resource_full_mock_user_id"
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table "resource_full_mock_users", :force => true do |t|
      t.string   "first_name"
      t.string   "last_name"
      t.date     "birthdate"
      t.string   "email"
      t.string   "join_date"
      t.integer  "income"
      t.integer  "resource_full_mock_employer_id"
      t.string   "type"
      t.timestamps
    end
    
    ActiveRecord::Base.connection.create_table "resource_full_mock_employers", :force => true do |t|
      t.string "name"
      t.string "email"
      t.timestamps
    end
    
    ActiveRecord::Base.connection.create_table "resource_full_namespaced_mock_records", :force => true do |t|
      t.string "name"
      t.timestamps
    end
  end
end

ActionController::Routing::Routes.draw do |map|
  map.foo '/foo', :controller => 'resource_full_mocks', :action => 'foo'
  map.resources :resource_full_mocks, :resource_full_sub_mocks, :resource_full_mock_addresses
  map.resources :resource_full_mock_users, :collection => {:count => :get} do |users|
    users.resources :resource_full_mock_addresses
  end
  map.resources :resources, :controller => 'resource_full/controllers/resources' do |resource|
    resource.resources :routes, :controller => 'resource_full/controllers/routes'
  end
  map.resources :resource_full_namespaced_mock_records
  map.resources :resource_full_namespaced_mock_record_with_xml_overrides
end

class ResourceFullMock
  def self.table_name; "mock"; end
end
class ResourceFullSubMock < ResourceFullMock; end

# TODO Remove these or find a better way to handle ActiveRecord dependencies.
class ResourceFullMockEmployer < ActiveRecord::Base
  has_many :resource_full_mock_users
end

class ResourceFullMockUser < ActiveRecord::Base
  belongs_to :resource_full_mock_employer
  has_many :resource_full_mock_addresses
end

class ResourceFullMockSubUser < ResourceFullMockUser
end

class ResourceFullMockAddress < ActiveRecord::Base
  belongs_to :resource_full_mock_user
end

class ResourceFullMocksController < ResourceFull::Base
  # dispatch_spec custom methods spec, approx. line 98
  def foo
    render :xml => { :foo => "bar" }.to_xml
  end
end
class ResourceFullSubMocksController < ResourceFullMocksController; end
class ResourceFullMockUsersController < ResourceFull::Base;         end
class ResourceFullMockAddressesController < ResourceFull::Base;     end

module ResourceFullSpec
  class ResourceFullNamespacedMockRecord < ActiveRecord::Base
  end
end
class ResourceFullNamespacedMockRecordsController < ResourceFull::Base
  exposes ResourceFullSpec::ResourceFullNamespacedMockRecord
end
class ResourceFullNamespacedMockRecordWithXmlOverridesController < ResourceFull::Base
  exposes ResourceFullSpec::ResourceFullNamespacedMockRecord
  def show_xml_options;   {:root => 'my_show_root'};   end
  def index_xml_options;  {:root => 'my_index_roots'}; end
  def create_xml_options; {:root => 'my_create_root'}; end
  def update_xml_options; {:root => 'my_update_root'}; end
  def new_xml_options;    {:root => 'my_new_root'};    end
end

ActionController::Routing.use_controllers! %w{ 
  resource_full_mock_users 
  resource_full_mock_addresses 
  resource_full_mocks
  resource_full_sub_mocks
  resource_full/controllers/routes
  resource_full/controllers/resources
}

def putsh(stuff); puts ERB::Util.h(stuff) + "<br/>"; end
def ph(stuff); puts ERB::Util.h(stuff.inspect) + "<br/>"; end
