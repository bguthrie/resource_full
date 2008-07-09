module ActionResource
  module Query
    QUERY_DELIMITER = ','
    
    class << self      
      def included(base)
        super(base)
        base.send(:extend, ClassMethods)
      end
    end
    
    module ClassMethods
      def queryable_with(*args)
        opts = args.last.is_a?(Hash) ? args.pop : {}
        self.queryable_params += args.collect {|param| ActionResource::Query::Parameter.new(param, self, opts.dup)}
      end
      
      def joins
        @joins ||= []
      end
      
      def queryable_params
        @queryable_params ||= []
      end
      
      def queryable_params=(params)
        @queryable_params = params
      end
      
      def nests_within(*resources)
        resources.each do |resource|
          expected_nest_id = "#{resource.to_s.singularize}_id"
          queryable_with expected_nest_id, :from => resource.to_sym, :resource_identifier => true
        end
      end
    end
    
    def queried_conditions
      query_arrays = self.class.queryable_params.collect do |query_param|
        query_param.conditions_for(params)
      end.reject(&:empty?)
      
      merged_strings = query_arrays.collect {|ary| "(#{ary.shift})"}.join(' AND ')
      
      [ merged_strings ] + query_arrays.sum([])
    end
  end
end