module ResourceFull
  module Render
    module XML
      protected

      def show_xml_options
        {}
      end
      def show_xml
        self.model_object = send("find_#{model_name}")
        render :xml => model_object.to_xml({:root => model_name}.merge(show_xml_options))
      rescue ActiveRecord::RecordNotFound => e
        render :xml => e.to_xml, :status => :not_found
      rescue => e
        handle_generic_error_in_xml(e)
      end

      def index_xml_options
        {}
      end
      def index_xml
        self.model_objects = send("find_all_#{model_name.pluralize}")
        root_tag = model_objects.all? { |e| e.is_a?(model_objects.first.class) && model_objects.first.class.to_s != "Hash" } ? model_objects.first.class.simple_name.underscore.pluralize : model_name.pluralize
        render :xml => model_objects.to_xml({:root => root_tag}.merge(index_xml_options))
      end

      def create_xml_options
        {}
      end
      def create_xml
        self.model_object = send("create_#{model_name}")
        if model_object.errors.empty?
          render :xml => model_object.to_xml({:root => model_name}.merge(create_xml_options)), :status => :created, :location => send("#{model_name}_url", model_object.id)
        else
          render :xml => model_object.errors.to_xml, :status => status_for(model_object.errors)
        end
      rescue => e
        handle_generic_error_in_xml(e)
      end

      def update_xml_options
        {}
      end
      def update_xml
        self.model_object = send("update_#{model_name}")
        if model_object.errors.empty?
          render :xml => model_object.to_xml({:root => model_name}.merge(update_xml_options))
        else
          render :xml => model_object.errors.to_xml, :status => status_for(model_object.errors)
        end
      rescue ActiveRecord::RecordNotFound => e
        render :xml => e.to_xml, :status => :not_found
      rescue => e
        handle_generic_error_in_xml(e)
      end

      def destroy_xml
        self.model_object = send("destroy_#{model_name}")
        head :ok
      rescue ActiveRecord::RecordNotFound => e
        render :xml => e.to_xml, :status => :not_found
      rescue => e
        handle_generic_error_in_xml(e)
      end

      def new_xml_options
        {}
      end
      def new_xml
        render :xml => send("new_#{model_name}").to_xml({:root => model_name}.merge(new_xml_options))
      end

      private
      def handle_generic_error_in_xml(exception)
        render :xml => exception, :status => :unprocessable_entity
      end
    end
  end
end
