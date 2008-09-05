module ResourceFull
  module Query
    # A Parameter represents the information necessary to describe a query relationship.  It's inherently
    # tied to ActiveRecord at the moment, unfortunately.  Objects of this class should not be instantiated
    # directly; instead, use the +queryable_with+ method.
    class Parameter
      attr_reader :name, :columns
    
      def initialize(name, resource, opts={})
        @resource = resource        
        @name     = name
        @fuzzy    = opts[:fuzzy] || false
        @columns  = opts[:columns] || [ opts[:column] || name ]
      end
      
      def fuzzy?; @fuzzy; end
      
      def table
        @resource.model_class.table_name
      end
      
      def from
        @resource.model_name
      end
      
      # Returns a new Parameter with its target resource altered, for cases in which a resource is subclassed.
      def subclass(new_resource)
        self.class.new(
          @name,
          new_resource,
          :fuzzy => @fuzzy,
          :columns => @column
        )
      end
      
      def conditions_for(params)
        values = param_values_for(params)
        unless values.empty?
          final_query_string = values.collect { |value| query_string(value) }.join(" OR ")
          final_values       = values.sum([]) { |value| Array.new(columns.size, value) }
          
          [ final_query_string ] + final_values
        else [] end
      end
      
      def to_xml(opts={})
        {
          :name => name.to_s,
          :fuzzy => fuzzy?,
          :from => from.to_s,
          :columns => columns.join(",")
        }.to_xml(opts.merge(:root => "parameter"))
      end
      
      private
      
        def param_values_for(params)
          values = (params[self.name] || params[self.name.to_s.pluralize] || '').split(',')
          values.map! {|value| "%#{value}%" } if fuzzy?
          values
        end
      
        def query_string(value)
          columns.collect do |column|
            # Convert to a column name if column is a proc.
            column = column.call(value) if column.is_a?(Proc)
            if fuzzy?
              "(#{table}.#{column} LIKE ?)"
            else
              "(#{table}.#{column} = ?)"
            end
          end.join(" OR ")
        end
      
    end
  end
end