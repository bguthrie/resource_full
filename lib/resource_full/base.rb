module ResourceFull
  class Base < ActionController::Base  
    session :off, :if => lambda { |request| request.format.xml? || request.format.json? }

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
        "#{resource.to_s.underscore}_controller".classify.constantize
      end
      alias_method :[], :controller_for
      
      private
      
        def inherited(controller)
          super(controller)
          controller.send :extend, ClassMethods
          controller.send :include, 
            ResourceFull::Retrieve, 
            ResourceFull::Query, 
            ResourceFull::Dispatch, 
            ResourceFull::Render
          controller.send :alias_retrieval_methods!
        end
    end
  end

  module ClassMethods
    attr_accessor_with_default :resource_identifier, :id
    attr_accessor_with_default :paginatable, true
    
    # Returns true if this resource is paginatable, which is to say, it recognizes and honors
    # the :limit and :offset parameters if present in a query.  True by default.
    def paginatable?; paginatable; end
    
    # The name of the model exposed by this resource.  Derived from the name of the controller
    # by default.  See +exposes+.
    def model_name
      @model_class ? @model_class.to_s.underscore : self.controller_name.singularize
    end
    
    # Indicates that this resource is identified by a database column other than the default
    # :id.  TODO This should honor the model's primary key column but needn't be bound by it.
    def identified_by(column_name)
      self.resource_identifier = column_name
    end
    
    # The class of the model exposed by this resource.  Derived from the model name.  See +exposes+.
    def model_class
      @model_class || model_name.camelize.constantize
    end

    # Indicates that the CRUD methods should be called on the given class.  Accepts
    # either a class object or the name of the desired model.
    def exposes(model_class)
      remove_retrieval_methods!
      @model_class = model_class.to_s.singularize.camelize.constantize
      alias_retrieval_methods!
    end
    
    # Renders the resource as XML.
    def to_xml(opts={})
      {
        :name       => self.model_name,
        :parameters => self.queryable_params,
        :identifier => self.resource_identifier
      }.to_xml(opts.merge(:root => "resource"))
    end
        
    private
    
      def alias_retrieval_methods!
        alias_method "new_#{model_name}",                 :new_model_object
        alias_method "find_#{model_name}",                :find_model_object
        alias_method "create_#{model_name}",              :create_model_object
        alias_method "update_#{model_name}",              :update_model_object
        alias_method "destroy_#{model_name}",             :destroy_model_object
        alias_method "find_all_#{model_name.pluralize}",  :find_all_model_objects
        alias_method "count_all_#{model_name.pluralize}", :count_all_model_objects
      end
      
      def remove_retrieval_methods!
        remove_method "new_#{model_name}"
        remove_method "find_#{model_name}"
        remove_method "create_#{model_name}"
        remove_method "update_#{model_name}"
        remove_method "destroy_#{model_name}"
        remove_method "find_all_#{model_name.pluralize}"
        remove_method "count_all_#{model_name.pluralize}"
      end
  end
end