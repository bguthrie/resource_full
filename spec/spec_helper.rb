# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + '/../../../../config/environment')  
require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/vendor/plugins/resource_full/spec/fixtures/'
  config.mock_with :mocha
end

class MocksController < ResourceFull::Base
end

class SubMocksController < MocksController
end

class Mock # To emulate ActiveRecord.
  def self.table_name; "mocks"; end
end

class UsersController < ResourceFull::Base
end

class AddressesController < ResourceFull::Base
end

# TODO Remove these or find a better way to handle ActiveRecord dependencies.
class User < ActiveRecord::Base
  class << self
    attr_accessor_with_default :skip_validation, :true
  end
  has_many :addresses
  def skip_validation?; self.class.skip_validation; end
end

class Address < ActiveRecord::Base
  belongs_to :user
end

def putsh(stuff); puts ERB::Util.h(stuff) + "<br/>"; end
def ph(stuff); puts ERB::Util.h(stuff.inspect) + "<br/>"; end


ActionController::Routing::Routes.draw do |map|
  map.foo '/foo', :controller => 'mocks', :action => 'foo'
  map.resources :mocks
  map.resources :users, :collection => {:count => :get} do |users|
    users.resources :addresses
  end
  map.resources :sub_mocks
end