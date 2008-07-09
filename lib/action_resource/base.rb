module ActionResource
  class Base < ActionController::Base  
    session :off, :if => lambda { |request| request.format.xml? || request.format.json? }

    def model_name; self.class.model_name; end
    def model_class; self.class.model_class; end

    class << self
      def all_resources
        ActionController::Routing.possible_controllers.map do |possible_controller|
          controller_for(possible_controller)
        end.select do |controller_class|
          controller_class.ancestors.include?(self)
        end
      end
      
      def controller_for(resource)
        "#{resource.to_s.underscore}_controller".classify.constantize
      end
      alias_method :[], :controller_for
      
      def inherited(controller)
        super(controller)
        controller.send :extend, ClassMethods
        controller.send :include, 
          ActionResource::Retrieve, 
          ActionResource::Query, 
          ActionResource::Dispatch, 
          ActionResource::Render
      end
    end
  end

  module ClassMethods
    attr_accessor_with_default :resource_identifier, :id
    attr_accessor_with_default :paginatable, true
    
    def paginatable?; paginatable; end
    
    def model_name
      @model_class ? @model_class.to_s.underscore : self.controller_name.singularize
    end

    def model_class
      @model_class || model_name.camelize.constantize
    end

    # Indicates that the CRUD methods should be called on the given class.
    def exposes(model_class)
      @model_class = model_class.to_s.singularize.camelize.constantize
    end

    def responds_to(*formats)
      @formats = formats
    end

    def renderable_formats
      @formats || [ :xml, :html ]
    end
    
    def to_xml(opts={})
      {
        :name       => self.model_name,
        :parameters => self.queryable_params,
        :identifier => self.resource_identifier
      }.to_xml(opts.merge(:root => "resource"))
    end
  end
end