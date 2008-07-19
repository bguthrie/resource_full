module ResourceFull
  module Query
    class Parameter
      attr_reader :name, :fuzzy, :columns, :table, :from
      alias_method :fuzzy?, :fuzzy
    
      def initialize(name, resource, opts={})
        if opts[:from]
          resource.joins << opts[:from]
          begin
            target_resource = ResourceFull::Base.controller_for(opts[:from].to_s.pluralize)
            opts[:column] ||= target_resource.resource_identifier if opts[:resource_identifier]
            @table = target_resource.model_class.table_name
            @from = opts[:from]
          rescue NameError => e
            warn e.message
            target_model = opts[:from].to_s.singularize.classify.constantize
            @table = target_model.table_name
            @from  = target_model.name.underscore
          end
        else
          @table = resource.model_class.table_name
          @from  = resource.model_name
        end
        
        @name    = name
        @fuzzy   = opts[:fuzzy] || false
        @columns = opts[:columns] || [ opts[:column] || name ]
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
          :fuzzy => fuzzy,
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
  end
end