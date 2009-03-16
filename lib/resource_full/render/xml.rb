module ResourceFull
  module Render
    module XML
      protected
  
      def show_xml
        self.model_object = send("find_#{model_name}")
        render :xml => model_object.to_xml
      rescue ActiveRecord::RecordNotFound => e
        render :xml => e.to_xml, :status => :not_found
      end

      def index_xml
        self.model_objects = send("find_all_#{model_name.pluralize}")
        render :xml => model_objects.to_xml
      end

      def create_xml
        self.model_object = send("create_#{model_name}")
        if model_object.valid?
          render :xml => model_object.to_xml, :status => :created, :location => send("#{model_name}_url", model_object.id)
        else
          render :xml => model_object.errors.to_xml, :status => status_for(model_object.errors)
        end
      end

      def update_xml
        self.model_object = send("update_#{model_name}")      
        if model_object.valid?
          render :xml => model_object.to_xml
        else
          render :xml => model_object.errors.to_xml, :status => status_for(model_object.errors)
        end
      rescue ActiveRecord::RecordNotFound => e
        render :xml => e.to_xml, :status => :not_found
      end

      def destroy_xml
        self.model_object = send("destroy_#{model_name}")
        head :ok
      rescue ActiveRecord::RecordNotFound => e
        render :xml => e.to_xml, :status => :not_found
      end
  
      def new_xml
        render :xml => send("new_#{model_name}").to_xml
      end
    end
  end
end
