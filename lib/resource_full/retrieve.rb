module ResourceFull
  module Retrieve
    class << self
      def included(base)
        super(base)
        # Define new_person, update_person, etc.
        base.before_filter :move_queryable_params_into_model_params_on_create, :only => [:create]
      end
    end

    protected

    def find_model_object
      # TODO I am not sure what the correct behavior should be here, but I'm artifically
      # generating the exception in order to avoid altering the render methods for the time being.
      returning(model_class.find(:first, :conditions => { resource_identifier => params[:id] })) do |o|
        raise ActiveRecord::RecordNotFound, "Couldn't find #{model_class} with #{resource_identifier}=#{params[:id]}" if o.nil?
      end
    end

    def new_model_object
      model_class.new
    end

    # Decorate the method with this - so that even if the user has overridden this method, it will get decorated within a transaction!
    [:create, :update, :destroy].each do |action|
      send(:define_method, "transactional_#{action}_model_object") do
        result = nil
        ActiveRecord::Base.transaction do
          result = send("#{action}_#{model_name}")
          raise ActiveRecord::Rollback unless result.errors.empty?
        end
        result
      end
    end

    def update_model_object
      object = find_model_object
      object.update_attributes(params[model_name])
      object
    end

    def create_model_object
      model_class.create(params[model_name])
    end

    def destroy_model_object
      object = find_model_object
      object.destroy
      object
    end

    def find_all_model_objects
      completed_query.find(:all)
    end

    def count_all_model_objects
      completed_query.count
    end

    def move_queryable_params_into_model_params_on_create
      params.except(model_name).each do |param_name, value|
        if self.class.queryable_params.collect(&:name).include?(param_name.to_sym)
          params[model_name][param_name] = params.delete(param_name)
        end
      end
    end

    private

      def completed_query
        self.class.queryable_params.inject(model_class) do |finder, queryer|
          queryer.find finder, params
        end
      end

      def resource_identifier
        returning(self.class.resource_identifier) do |column|
          return column.call(params[:id]) if column.is_a?(Proc)
        end
      end
  end
end
