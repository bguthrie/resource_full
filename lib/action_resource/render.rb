module ActionResource
  module Render
    def show_xml
      render :xml => model_object
    rescue ActiveRecord::RecordNotFound => e
      render :xml => e.to_xml, :status => :not_found
    end
    
    def index_xml
      render :xml => model_objects
    end
    
    def create_xml
      if model_object.valid?
        render :xml => model_object, :location => { :id => model_object.id }
      else
        render :xml => model_object.errors, :status => status_for(model_object.errors)
      end
    end
    
    def update_xml
      if model_object.valid?
        render :xml => model_object
      else
        render :xml => model_object.errors, :status => status_for(model_object.errors)
      end
    rescue ActiveRecord::RecordNotFound => e
      render :xml => e.to_xml, :status => :not_found
    end
    
    def destroy_xml
      head :ok
    rescue ActiveRecord::RecordNotFound => e
      render :xml => e.to_xml, :status => :not_found
    end
  
    def show_html
    rescue ActiveRecord::RecordNotFound => e
      flash[:error] = e.message
    end
    
    def index_html
    end
    
    def create_html
      if model_object.valid?
        flash[:info] = "Successfully created #{model_name.humanize} with ID of #{model_object.id}."
        redirect_to :action => :index, :format => :html
      else
        render :action => "new"
      end
    end
    
    def update_html
      if model_object.valid?
        flash[:info] = "Successfully updated #{model_name.humanize} with ID of #{model_object.id}."
        redirect_to :action => :index, :format => :html
      else
        render :action => "edit"
      end
    end
    
    def destroy_html
      flash[:info] = "Successfully destroyed #{model_name.humanize} with ID of #{params[:id]}."
      redirect_to :action => :index, :format => html
    rescue ActiveRecord::RecordNotFound => e
      flash[:error] = e.message
      redirect_to :back
    end
    
  end
  
  private
  
  CONFLICT_MESSAGE = if defined?(ActiveRecord::Errors) 
    ActiveRecord::Errors.default_error_messages[:taken]
  else 
    "has already been taken"
  end

  def status_for(errors)
    if errors.any? { |message| message.include? CONFLICT_MESSAGE }
      :conflict
    else :unprocessable_entity end
  end
end