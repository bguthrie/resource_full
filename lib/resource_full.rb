# Dependencies
require 'active_record'
require 'action_controller'
require 'action_pack'

# Extensions
Dir[File.dirname(__FILE__) + "/resource_full/core_extensions/*.rb"].each do |extension|
  require extension
end

# Core library
require File.dirname(__FILE__) + '/resource_full/dispatch'
require File.dirname(__FILE__) + '/resource_full/query'

require File.dirname(__FILE__) + '/resource_full/render/html'
require File.dirname(__FILE__) + '/resource_full/render/json'
require File.dirname(__FILE__) + '/resource_full/render/xml'

require File.dirname(__FILE__) + '/resource_full/render'
require File.dirname(__FILE__) + '/resource_full/retrieve'
require File.dirname(__FILE__) + '/resource_full/version'
require File.dirname(__FILE__) + '/resource_full/base'

# REST API
require File.dirname(__FILE__) + '/resource_full/models/resourced_route'
require File.dirname(__FILE__) + '/resource_full/controllers/resources_controller'
require File.dirname(__FILE__) + '/resource_full/controllers/routes_controller'
