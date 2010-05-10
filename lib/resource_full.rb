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

module ResourceFull
  class ResourceNotFound < Exception; end
  
  def model_name; self.class.model_name; end
  def model_class; self.class.model_class; end

  class << self
    # Returns the list of all resources handled by ResourceFull.
    def all_resources
      ActionController::Routing.possible_controllers.map do |possible_controller|
        controller_for(possible_controller)
      end.select do |controller_class|
        controller_class.ancestors.include?(self)
      end
    end
    
    # Returns the controller for the given resource.
    def controller_for(resource)
      return resource if resource.is_a?(Class) && resource.ancestors.include?(ActionController::Base)
      "#{resource.to_s.underscore}_controller".classify.constantize
    rescue NameError
      raise ResourceFull::ResourceNotFound, "not found: #{resource}"
    end
    
    private
    
      def included(controller)
        controller.send :extend, ClassMethods
        controller.send :include, 
          ResourceFull::Retrieve, 
          ResourceFull::Query, 
          ResourceFull::Dispatch, 
          ResourceFull::Render
        
        if ActionPack::VERSION::STRING < "2.3.0"
          controller.session :off, :if => lambda { |request| request.format.xml? || request.format.json? }
        end
      end
  end
  
  
  module ClassMethods
    attr_accessor_with_default :paginatable, true
    attr_accessor_with_default :resource_identifier, :id
    
    # Returns true if this resource is paginatable, which is to say, it recognizes and honors
    # the :limit and :offset parameters if present in a query.  True by default.
    def paginatable?; paginatable; end
    
    # The name of the model exposed by this resource.  Derived from the name of the controller
    # by default.  See +exposes+.
    def model_name
      @model_class ? @model_class.name.demodulize.underscore : self.controller_name.singularize
    end
    
    # Indicates that this resource is identified by a database column other than the default
    # :id.  
    # TODO This should honor the model's primary key column but needn't be bound by it.
    # TODO Refactor this.
    # TODO Improve the documentation.
    def identified_by(*args, &block)
      opts = args.extract_options!
      column = args.first
      if !block.nil?
        self.resource_identifier = block
      elsif !column.nil?
        if !opts.empty? && ( opts.has_key?(:if) || opts.has_key?(:unless) )
          if opts[:unless] == :id_numeric
            opts[:unless] = lambda { |id| id =~ /^[0-9]+$/ }
          end
          
          # Negate the condition to generate an :if from an :unless.
          condition = opts[:if] || lambda { |id| not opts[:unless].call(id) }
          
          self.resource_identifier = lambda do |id|
            if condition.call(id)
              column
            else :id end
          end
        else
          self.resource_identifier = column
        end
      else
        raise ArgumentError, "identified_by expects either a block or a column name and some options"
      end
    end
    
    # The class of the model exposed by this resource.  Derived from the model name.  See +exposes+.
    def model_class
      @model_class ||= model_name.camelize.constantize
    end

    # Indicates that the CRUD methods should be called on the given class.  Accepts
    # either a class object or the name of the desired model.
    def exposes(model_class)
      @model_class = model_class.to_s.singularize.camelize.constantize
    end
    
    # Renders the resource as XML.
    def to_xml(opts={})
      { :name       => self.controller_name,
        :parameters => self.queryable_params,
        :identifier => self.xml_identifier
      }.to_xml(opts.merge(:root => "resource"))
    end
    
    protected
    
      def xml_identifier
        (self.resource_identifier.is_a?(Proc) ? self.resource_identifier.call(nil) : self.resource_identifier).to_s
      end
        
  end
end

# REST API
require File.dirname(__FILE__) + '/resource_full/models/resourced_route'
require File.dirname(__FILE__) + '/resource_full/controllers/resources_controller'
require File.dirname(__FILE__) + '/resource_full/controllers/routes_controller'