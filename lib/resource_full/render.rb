module ResourceFull
  module Render
    def self.included(controller)
      controller.rescue_from Exception, :with => :handle_generic_exception_with_correct_response_format
    end
    
    protected
      def json_class_name(obj)
        obj.class.name.demodulize.underscore
      end
      def show_json
        raise if $raise
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
    
      def show_xml
        raise if $raise
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
  
      def show_html
        self.model_object = send("find_#{model_name}")
      rescue ActiveRecord::RecordNotFound => e
        flash[:error] = e.message
      end
    
      def index_html
        self.model_objects = send("find_all_#{model_name.pluralize}")
      end
    
      def create_html
        self.model_object = send("create_#{model_name}")
        if model_object.valid?
          flash[:info] = "Successfully created #{model_name.humanize} with ID of #{model_object.id}."
          redirect_to :action => :index, :format => :html
        else
          render :action => "new"
        end
      end
    
      def update_html
        self.model_object = send("update_#{model_name}")      
        if model_object.valid?
          flash[:info] = "Successfully updated #{model_name.humanize} with ID of #{model_object.id}."
          redirect_to :action => :index, :format => :html
        else
          render :action => "edit"
        end
      end
    
      def destroy_html
        self.model_object = send("destroy_#{model_name}")
        flash[:info] = "Successfully destroyed #{model_name.humanize} with ID of #{params[:id]}."
        redirect_to :action => :index, :format => :html
      rescue ActiveRecord::RecordNotFound => e
        flash[:error] = e.message
        redirect_to :back
      end
      
      def new_html
        self.model_object = send("new_#{model_name}")
      end
  
    private
  
      CONFLICT_MESSAGE = if defined?(ActiveRecord::Errors) 
        if ([Rails::VERSION::MAJOR, Rails::VERSION::MINOR] <=> [2,1]) >= 0 # if the rails version is 2.1 or greater...Í
          (I18n.translate 'activerecord.errors.messages')[:taken]
        else
          ActiveRecord::Errors.default_error_messages[:taken]
        end
      else 
        "has already been taken"
      end

      def status_for(errors)
        if errors.any? { |message| message.include? CONFLICT_MESSAGE }
          :conflict
        else :unprocessable_entity end
      end
      
      def handle_generic_exception_with_correct_response_format(exception)
        if request.format.xml?
          if defined?(ExceptionNotifiable) && defined?(ExceptionNotifier) && self.is_a?(ExceptionNotifiable) && !(consider_all_requests_local || local_request?)
            deliverer = self.class.exception_data
             data = case deliverer
               when nil then {}
               when Symbol then send(deliverer)
               when Proc then deliverer.call(self)
             end
          
             ExceptionNotifier.deliver_exception_notification(exception, self,
               request, data)
          end
          logger.error exception.message + "\n" + exception.clean_backtrace.collect {|s| "\t#{s}\n"}.join
          render :xml => exception.to_xml, :status => :server_error
        elsif request.format.json?
          if defined?(ExceptionNotifiable) && defined?(ExceptionNotifier) && self.is_a?(ExceptionNotifiable) && !(consider_all_requests_local || local_request?)
            deliverer = self.class.exception_data
             data = case deliverer
               when nil then {}
               when Symbol then send(deliverer)
               when Proc then deliverer.call(self)
             end
          
             ExceptionNotifier.deliver_exception_notification(exception, self,
               request, data)
          end
          logger.error exception.message + "\n" + exception.clean_backtrace.collect {|s| "\t#{s}\n"}.join
          render :json => exception.to_json, :status => :server_error
        else
          raise exception
        end
      end
  end
end
