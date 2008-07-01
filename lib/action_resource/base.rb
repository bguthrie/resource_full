module ActionResource
  class Base < ActionController::Base  
    session :off, :if => lambda { |request| request.format.xml? || request.format.json? }

    def model_name; self.class.model_name; end
    def model_class; self.class.model_class; end

    class << self
      def inherited(base)
        super(base)
        base.send :extend, ClassMethods
        base.send :include, 
          ActionResource::Retrieve, 
          ActionResource::Query, 
          ActionResource::Dispatch, 
          ActionResource::Render
      end
    end
  end

  module ClassMethods
    def model_name
      @model_class ? @model_class.to_s.underscore : self.controller_name.singularize
    end

    def model_class
      @model_class || model_name.camelize.constantize
    end

    # Indicates that the CRUD methods should be called on the given class.
    def exposes(model_class)
      @model_class = model_class.to_s.camelize.constantize
    end

    def responds_to(*formats)
      @formats = formats
    end

    def renderable_formats
      @formats || [ :xml, :html ]
    end

    def nests(controller_name, opts={})
      nesting_id = "#{model_name}_id" || opts[:foreign_key]
      "#{controller_name}_controller".classify.constantize.queryable_params << nesting_id
    end
  end
end