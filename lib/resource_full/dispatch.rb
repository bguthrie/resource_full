module ResourceFull
  module Dispatch
    class << self
      def included(controller)
        super(controller)
        controller.send :extend, ClassMethods
        controller.before_filter :ensure_sets_format_when_ie7
        controller.before_filter :ensure_responds_to_format
        controller.before_filter :ensure_responds_to_method
      end
    end

    module ClassMethods
      DEFAULT_FORMATS = [ :xml, :html, :json ]

      CRUD_METHODS_TO_ACTIONS = {
        :create => [ :create, :new ],
        :read   => [ :show, :index, :count ],
        :update => [ :update, :edit ],
        :delete => [ :destroy ]
      }

      # usage:
      # register_action :index, :format => [:xml, :json]
      # register_action :update, :format => [:xml]
      def register_action(*actions)
        opts = actions.extract_options!
        @renderable_formats ||= default_responds
        formats = [opts[:format]].flatten
        formats.each do |format|
          @renderable_formats[format] ||= []
          @renderable_formats[format] += actions
        end
      end

      # Indicates that the controller responds to one of the requested CRUD (create, read,
      # update, delete) methods.  These correspond to controller methods in the following
      # manner:
      #
      # * Create: create, new
      # * Read: show, index, count
      # * Update: update, edit
      # * Delete: destroy
      #
      # By default, a format supports all of the above methods, unless you specify otherwise.
      # Override these defaults by using the :only or :except options.  For example,
      #
      #   responds_to :xml, :only => [:create, :delete]
      #
      # A controller may be reset back to default responds (xml, html, all CRUD methods) by
      # specifying responds_to :defaults.
      def responds_to(*formats)
        if formats.first == :defaults
          @renderable_formats = default_responds
          return
        end

        opts = formats.extract_options!

        supported_crud_methods = if opts[:only]
          [ opts[:only] ].flatten
        elsif opts[:except]
          CRUD_METHODS_TO_ACTIONS.keys - [ opts[:except] ].flatten
        else
          CRUD_METHODS_TO_ACTIONS.keys
        end
        @renderable_formats ||= {}
        formats.each do |format|
          @renderable_formats[format] ||= []
          @renderable_formats[format] += CRUD_METHODS_TO_ACTIONS.slice(*supported_crud_methods).values.flatten
          @renderable_formats[format].uniq!
        end
      end

      # A list of symbols of all allowed formats (e.g. :xml, :html)
      def allowed_formats
        renderable_formats.keys
      end

      # A list of symbols of all allowed controller actions (e.g. :show, :destroy) derived from
      # the allowed CRUD actions.
      def allowed_actions(format=:html)
        renderable_formats[format] || []
      end

      # A list of all possible CRUD actions that this framework understands, which is to say,
      # the core Rails actions plus +count+ (and perhaps others eventually).
      def possible_actions
        CRUD_METHODS_TO_ACTIONS.values.sum([])
      end

      # Returns true if the request format is an allowed format.
      def responds_to_request_format?(request)
        allowed_formats.include? extract_request_format(request)
      end

      # Returns true if the request action is an allowed action as defined by the allowed CRUD methods.
      def responds_to_request_action?(request, action)
        # TODO Consider using ActionController's +verify+ method in preference to this.
        # TODO We don't verify custom methods yet, so ignore them.
        # TODO: In response to the above todo, can we remove these lines - the one above and the one below?
        return true unless possible_actions.include?(action.to_sym)
        allowed_actions(extract_request_format(request)).include? action.to_sym
      end

      protected

        def renderable_formats
          @renderable_formats ||= default_responds
        end

      private

        def extract_request_format(request)
          request.format.html? ? :html : request.format.to_sym
        end

        def default_responds
          returning({}) do |responses|
            DEFAULT_FORMATS.each do |format|
              responses[format] = CRUD_METHODS_TO_ACTIONS.values.sum([])
            end
          end
        end
    end

    [:index, :count, :show, :new, :create, :edit, :update, :destroy].each do |name|
      define_method(name) { dispatch_to name }
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

    def ensure_sets_format_when_ie7
      if user_agent_ie7?
        if request_looks_like?('json', 'javascript')
          request.format = 'json'
        elsif request_looks_like?('xml')
          request.format = 'xml'
        else
          request.format = 'html'
        end
      end
    end

    def user_agent_ie7?
      request.headers["HTTP_USER_AGENT"] =~ /MSIE 7.0/
    end

    def request_looks_like?(*formats)
      formats.any? do |format|
        request.format.to_s =~ /#{format}/ || request.headers['REQUEST_URI'] =~ /\.#{format}[?]/
      end
    end

    def ensure_responds_to_format
      unless self.class.responds_to_request_format?(request)
        render :text => "Resource does not have a representation in #{request.format.to_str} format", :status => :not_acceptable
      end
    end

    def ensure_responds_to_method
      unless self.class.responds_to_request_action?(request, params[:action])
        render :text => "Resource does not allow #{params[:action]} action", :status => :method_not_allowed
      end
    end

    def dispatch_to(method)
      respond_to do |requested_format|
        # puts "requested_format: #{requested_format.inspect}"
        # TODO: Should we need to loop here? Cant we just select one and invoke that one alone?
        self.class.allowed_formats.each do |renderable_format|
          # puts "renderable_format: #{renderable_format.inspect}"
          requested_format.send(renderable_format) { send("#{method}_#{renderable_format}") }
        end
      end
    end
  end
end
