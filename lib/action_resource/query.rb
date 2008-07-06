module ActionResource
  module Query
    QUERY_DELIMITER = ','
    
    def self.included(base)
      base.send(:extend, ClassMethods)
      super(base)
    end
    
    module ClassMethods
      def queryable_with(*args)
        opts = args.last.is_a?(Hash) ? args.pop : {}
        self.queryable_params = args.collect {|param| QueryParameter.new(param, opts)}
      end
      
      def queryable_params
        @queryable_params ||= []
      end
      
      def queryable_params=(params)
        @queryable_params = params
      end
    end
    
    def queried_conditions
      query_arrays = self.class.queryable_params.collect do |query_param|
        query_param.conditions_for(params)
      end.reject(&:empty?)
      
      merged_strings = query_arrays.collect(&:shift).join(') AND (')
      merged_strings = "(#{merged_strings})"
      
      [ merged_strings ] + query_arrays.sum([])
    end
    
    class QueryParameter
      attr_reader :name
      
      def initialize(name, opts={})
        @name  = name
        @fuzzy = opts[:fuzzy]
      end
      
      def column; @name; end
      
      def fuzzy?; @fuzzy; end
      
      def conditions_for(params)
        values = param_values_for(params)
        unless values.empty?
          final_query_string = returning([]) {|ary| values.size.times { ary << query_string}}.join(") OR (")
          [ final_query_string ] + values
        else [] end
      end
      
      private
      
        def param_values_for(params)
          values = (params[self.name] || params[self.name.to_s.pluralize] || '').split(',')
          values.map! {|value| "%#{value}%" } if fuzzy?
          values
        end
      
        def query_string
          if fuzzy?
            "#{column} LIKE ?"
          else
            "#{column} = ?"
          end
        end
      
    end
  end
end