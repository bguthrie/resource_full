module ResourceFull
  module Render
    module JSON
      protected

      def json_class_name(obj)
        obj.class.name.demodulize.underscore
      end

      def show_json_options
        {}
      end
      def show_json
        self.model_object = send("find_#{model_name}")
        render :json => model_object.to_json(show_json_options)
      rescue ActiveRecord::RecordNotFound => e
        render :json => e.to_json, :status => :not_found
      rescue => e
        handle_generic_error_in_json(e)
      end

      def index_json_options
        {}
      end
      def index_json
        self.model_objects = send("find_all_#{model_name.pluralize}")
        render :json => model_objects.to_json(index_json_options)
      end

      def create_json_options
        {}
      end
      def create_json
        self.model_object = transactional_create_model_object
        if model_object.errors.empty?
          render :json => model_object.to_json(create_json_options), :status => :created, :location => send("#{model_name}_url", model_object.id)
        else
          json_data = model_object.attributes
          json_data[:errors] = {:list => model_object.errors,
                               :full_messages => model_object.errors.full_messages}
          render :json => {json_class_name(model_object) => json_data}.to_json, :status => status_for(model_object.errors)
        end
      rescue => e
        handle_generic_error_in_json(e)
      end

      def update_json_options
        {}
      end
      def update_json
        self.model_object = transactional_update_model_object
        if model_object.errors.empty?
          render :json => model_object.to_json(update_json_options)
        else
          json_data = model_object.attributes
          json_data[:errors] = {:list => model_object.errors,
                               :full_messages => model_object.errors.full_messages}
          render :json => {json_class_name(model_object) => json_data}.to_json, :status => status_for(model_object.errors)
        end
      rescue ActiveRecord::RecordNotFound => e
        render :json => e.to_json, :status => :not_found
      rescue => e
        handle_generic_error_in_json(e)
      end

      def destroy_json
        self.model_object = send("destroy_#{model_name}")
        if model_object.errors.empty?
          head :ok
        else
          json_data = model_object.attributes
          json_data[:errors] = {:list => model_object.errors,
                               :full_messages => model_object.errors.full_messages}
          render :json => {json_class_name(model_object) => json_data}.to_json, :status => :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound => e
        render :json => e.to_json, :status => :not_found
      rescue => e
        handle_generic_error_in_json(e)
      end

      def new_json_options
        {}
      end
      def new_json
        render :json => send("new_#{model_name}").to_json(new_json_options)
      end

      private
      def handle_generic_error_in_json(exception)
        render :json => exception, :status => :unprocessable_entity
      end
    end
  end
end
