module ActionResource
  module Dispatch
    def show
      self.model_object = send("find_#{model_name}")
      dispatch_to :show
    end
    
    def index
      self.model_objects = send("find_all_#{model_name.pluralize}")
      dispatch_to :index
    end
    
    def create
      self.model_object = send("create_#{model_name}")
      dispatch_to :create
    end
    
    def update
      self.model_object = send("update_#{model_name}")
      dispatch_to :update
    end
    
    def destroy
      self.model_object = send("destroy_#{model_name}")
      dispatch_to :destroy
    end
    
    def new
      self.model_object = send("new_#{model_name}")
    end
    
    def edit
      self.model_object = send("find_#{model_name}")
    end
    
    protected
    
    def model_object=(object)
      instance_variable_set "@#{model_name}", object
    end
    
    def model_object
      instance_variable_get "@#{model_name}"
    end
    
    def model_objects=(objects)
      instance_variable_set "@#{model_name.pluralize}", objects
    end
    
    def model_objects
      instance_variable_get "@#{model_name.pluralize}"
    end
    
    private
    
    def dispatch_to(method)
      respond_to do |requested_format|
        self.class.renderable_formats.each do |renderable_format|
          requested_format.send(renderable_format) { send("#{method}_#{renderable_format}") }
        end
      end
    end    
  end
end