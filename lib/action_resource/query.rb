module ActionResource
  module Query
    QUERY_DELIMITER = ','
    
    def self.included(base)
      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
      super(base)
    end
    
    module ClassMethods
      def queryable_with(*params)
        self.queryable_params = params
      end
      
      def queryable_params
        @queryable_params ||= []
      end
      
      def queryable_params=(params)
        @queryable_params = params
      end
    end
    
    module InstanceMethods
      def queried_conditions
        returning({}) do |conditions|
          self.class.queryable_params.each do |param_name|
            param_name = param_name.to_s.singularize
            conditions[param_name] = params[param_name].split(QUERY_DELIMITER) if params.has_key?(param_name)
          end
        end
      end
    end
  end
end