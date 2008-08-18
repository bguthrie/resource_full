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
          final_query_string = Array.new(values.size, query_string).join(" OR ")
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
      
        def query_string
          columns.collect do |column|
            if fuzzy?
              "(#{table}.#{column} LIKE ?)"
            else
              "(#{table}.#{column} = ?)"
            end
          end.join(" OR ")
        end
      
    end
    
    # The essential difference between this and its superclass is that a regular parameter will alter
    # its behavior if its target resource is subclassed, whereas a ForeignResourceParamter is inherently
    # tied to the resource specified by the :from parameter.
    class ForeignResourceParameter < Parameter
      attr_reader :table, :from
      def initialize(name, resource, opts={})
        resource.joins << opts[:from]
        
        begin
          target_resource = ResourceFull::Base.controller_for(opts[:from].to_s.pluralize)
          opts[:column] ||= target_resource.resource_identifier if opts[:resource_identifier]
          @table = target_resource.model_class.table_name
          @from = opts[:from]
        rescue NameError => e
          # Try to recover gracefully if we can't find that particular resource.
          warn e.message
          target_model = opts[:from].to_s.singularize.classify.constantize
          @table = target_model.table_name
          @from  = target_model.name.underscore
        end
        
        super(name, resource, opts)        
      end
    end
  end
end