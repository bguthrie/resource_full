module ActionResource
  module Retrieve
    class << self
      def included(base)
        super(base)
        # Define new_person, update_person, etc.
        base.send(:alias_method, "new_#{base.model_name}",                :new_model_object)
        base.send(:alias_method, "find_#{base.model_name}",               :find_model_object)
        base.send(:alias_method, "create_#{base.model_name}",             :create_model_object)
        base.send(:alias_method, "update_#{base.model_name}",             :update_model_object)
        base.send(:alias_method, "destroy_#{base.model_name}",            :destroy_model_object)
        base.send(:alias_method, "find_all_#{base.model_name.pluralize}", :find_all_model_objects)
        base.before_filter :move_queryable_params_into_model_params_on_create, :only => [:create]
      end
    end
    
    # Override this to provide custom find conditions.  This is automatically merged at query
    # time with the queried conditions extracted from params.
    def find_options
      { :order => 'created_at DESC' }
    end
    
    protected
    
    def find_model_object
      model_class.find(:first, :conditions => { self.class.resource_identifier => params[:id]})
    end
  
    def new_model_object
      model_class.new
    end
    
    def update_model_object
      returning(find_model_object) do |object|
        object.update_attributes params[model_name]
      end
    end
    
    def create_model_object
      model_class.create(params[model_name])
    end
    
    def destroy_model_object
      model_class.destroy_all(self.class.resource_identifier => params[:id])
    end
  
    def find_all_model_objects(reload=false)
      model_class.find(:all, find_options_and_query_conditions)
    end
    
    def find_options_and_query_conditions
      returning(opts = find_options) do
        opts.merge!(:conditions => queried_conditions) unless queried_conditions.empty?
      end
    end
    
    def move_queryable_params_into_model_params_on_create
      params.except(model_name).each do |param_name, value|
        if self.class.queryable_params.include?(param_name.to_sym)
          params[model_name][param_name] = params.delete(param_name)
        end
      end
    end
  end
end