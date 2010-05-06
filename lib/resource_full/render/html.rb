module ResourceFull
  module Render
    module HTML
      protected

      def show_html
        self.model_object = self.find_model_object
      rescue ActiveRecord::RecordNotFound => e
        flash[:error] = e.message
      rescue => e
        flash[:error] = e.message
        redirect_to :back
      end

      def index_html
        self.model_objects = self.find_all_model_objects
      end

      def count_html
        self.count_all_model_objects
      end

      def new_html
        self.model_object = self.new_model_object
      end

      def create_html
        self.model_object = transactional_create_model_object
        if model_object.errors.empty?
          flash[:info] = "Successfully created #{model_name.humanize} with ID of #{model_object.id}."
          redirect_to :action => :index, :format => :html
        else
          render :action => "new"
        end
      rescue => e
        flash[:error] = e.message
        redirect_to :back
      end

      def edit_html
        self.model_object = self.edit_model_object
      end

      def update_html
        self.model_object = transactional_update_model_object
        if model_object.errors.empty?
          flash[:info] = "Successfully updated #{model_name.humanize} with ID of #{model_object.id}."
          redirect_to :action => :index, :format => :html
        else
          render :action => "edit"
        end
      rescue => e
        flash[:error] = e.message
        redirect_to :back
      end

      def destroy_html
        self.model_object = transactional_destroy_model_object
        if model_object.errors.empty?
          flash[:info] = "Successfully destroyed #{model_name.humanize} with ID of #{params[:id]}."
          redirect_to :action => :index, :format => :html
        else
          flash[:error] = model_object.errors
        end
      rescue ActiveRecord::RecordNotFound => e
        flash[:error] = e.message
        redirect_to :back
      rescue => e
        flash[:error] = e.message
        redirect_to :back
      end
    end
  end
end
