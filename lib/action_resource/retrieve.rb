module ActionResource
  module Retrieve
    class << self
      def included(base)
        super(base)
        # Define new_person, update_person, etc.
        base.before_filter :move_queryable_params_into_model_params_on_create, :only => [:create]
      end
    end
    
    # Override this to provide custom find conditions.  This is automatically merged at query
    # time with the queried conditions extracted from params.
    def find_options
      { :order => "#{model_class.table_name}.created_at DESC" }
    end
    
    protected
    
    # TODO Method aliasing is messy here because the model is overridable.  Find a nicer way to handle this.
    def method_missing(method, *args, &block)
      method_name = method.to_s
      if method_name.include?(model_name)
        send(method_name.gsub(model_name, "model_object"))
      else 
        super(method, *args, &block)
      end
    end
    
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
    
    def count_all_model_objects
      model_class.count(find_options_and_query_conditions)
    end
    
    def find_options_and_query_conditions
      returning(opts = find_options) do
        opts.merge!(:conditions => queried_conditions) unless queried_conditions.empty?
        opts.merge!(:joins => self.class.joins) unless self.class.joins.empty?
        opts.merge!(params.slice(:limit, :offset).symbolize_keys) if self.class.paginatable?
      end
    end
    
    def move_queryable_params_into_model_params_on_create
      params.except(model_name).each do |param_name, value|
        if self.class.queryable_params.collect(&:name).include?(param_name.to_sym)
          params[model_name][param_name] = params.delete(param_name)
        end
      end
    end
  end
end