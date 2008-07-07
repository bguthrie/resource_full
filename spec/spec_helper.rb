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
  config.fixture_path = RAILS_ROOT + '/vendor/plugins/action_resource/spec/fixtures/'
  config.mock_with :mocha
end

class MocksController < ActionResource::Base
end

class Mock # To emulate ActiveRecord.
end

# TODO Remove this or find a better way to handle ActiveRecord dependencies.
class UsersController < ActionResource::Base
end

class User < ActiveRecord::Base
end

def putsh(stuff); puts ERB::Util.h(stuff); end

ActionController::Routing::Routes.draw do |map|
  map.resources :mocks
  map.resources :users
  map.resources :overridable_mocks
end