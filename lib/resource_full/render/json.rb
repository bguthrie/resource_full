module ResourceFull
  module Render
    module JSON
      protected
  
      def json_class_name(obj)
        obj.class.name.demodulize.underscore
      end
  
      def show_json
        self.model_object = send("find_#{model_name}")
          render :json => model_object.to_json
      rescue ActiveRecord::RecordNotFound => e
        render :json => e.to_json , :status => :not_found
      end

      def index_json
        self.model_objects = send("find_all_#{model_name.pluralize}")
        render :json => model_objects.to_json
      end

      def create_json
        self.model_object = send("create_#{model_name}")
        if model_object.valid?
          render :json => model_object.to_json, :status => :created, :location => send("#{model_name}_url", model_object.id)
        else
          json_data = model_object.attributes
          json_data[:errors] = {:list => model_object.errors,
                               :full_messages => model_object.errors.full_messages}
          render :json => {json_class_name(model_object) => json_data}.to_json , :status => status_for(model_object.errors)
        end
      end

      def update_json
        self.model_object = send("update_#{model_name}")      
        if model_object.valid?
          render :json => model_object.to_json
        else
          json_data = model_object.attributes
          json_data[:errors] = {:list => model_object.errors,
                               :full_messages => model_object.errors.full_messages}
          render :json => {json_class_name(model_object) => json_data}.to_json , :status => status_for(model_object.errors)
        end
      rescue ActiveRecord::RecordNotFound => e
        render :json => e.to_json , :status => :not_found
      end

      def destroy_json
        self.model_object = send("destroy_#{model_name}")
        head :ok
      rescue ActiveRecord::RecordNotFound => e
        render :json => e.to_json , :status => :not_found
      end
  
      def new_json
        render :json => send("new_#{model_name}").to_json
      end
    end
  end
end