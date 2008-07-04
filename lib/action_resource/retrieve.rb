module ActionResource
  module Retrieve
    class << self
      def included(base)
        super(base)
        # Define new_person, update_person, etc.
        base.class_eval do
          alias_method "new_#{base.model_name}",                :new_model_object
          alias_method "find_#{base.model_name}",               :find_model_object
          alias_method "create_#{base.model_name}",             :create_model_object
          alias_method "update_#{base.model_name}",             :update_model_object
          alias_method "destroy_#{base.model_name}",            :destroy_model_object
          alias_method "find_all_#{base.model_name.pluralize}", :find_all_model_objects
        end
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
      model_class.update(params[:id], params[model_name])
    end
    
    def create_model_object
      model_class.create(params[model_name])
    end
    
    def destroy_model_object
      model_class.destroy(params[:id])
    end
  
    def find_all_model_objects(reload=false)
      model_class.find(:all, find_options_and_query_conditions)
    end
    
    def find_options_and_query_conditions
      returning(opts = find_options) do
        opts.merge!(:conditions => queried_conditions) unless queried_conditions.empty?
      end
    end 
  end
end