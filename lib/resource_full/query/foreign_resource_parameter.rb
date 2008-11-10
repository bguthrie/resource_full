module ResourceFull
  module Query
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
          target_model = resource.model_class.reflect_on_association(opts[:from]).class_name.constantize
          @table = target_model.table_name
          @from  = target_model.name.underscore
        end
        
        super(name, resource, opts)        
      end
    end
  end
end