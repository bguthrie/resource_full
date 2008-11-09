module ResourceFull
  module Models
    class RouteNotFound < Exception
    end
    
    class ResourcedRoute
      attr_reader :verb, :name, :pattern, :action, :controller
    
      class << self
        def find(what, opts={})
          case what
          when :all
            find_all_routes(opts)
          else
            find_named_route(what)
          end
        end
                
        def find_named_route(name)
          all_named_routes.find {|route| route.name == name} or raise ResourceFull::Models::RouteNotFound, "Could not find route #{name}" 
        end
        
        def find_all_routes(opts={})
          all_named_routes.sort_by(&:name)
        end
        
        private
          
          # Translates an AR route into something a little more human-friendly, adding some extra
          # relationships as it goes and cutting out the stuff we're not interested in--for example, 
          # formatted variants of regular routes.
          def all_named_routes
            # ActionController::Routing::Routes.named_routes.routes.values.each {|o| ph o}
            @all_named_routes ||= ActionController::Routing::Routes.named_routes.routes.collect do |name, route|
              verb = route.conditions[:method].to_s.upcase
              segs = route.segments.join
              new(
                :name     => name,
                :verb     => verb,
                :pattern  => segs,
                :action   => route.requirements[:action],
                :controller => route.requirements[:controller]
              )
            end.reject do |route|
              route.formatted? || !route.resourced? # || (opts[:resource_id] && opts[:resource_id] != route.resource)
            end
          end
          
      end
    
      def initialize(opts={})
        @verb     = opts[:verb]
        @name     = opts[:name]
        @pattern  = opts[:pattern]
        @action   = opts[:action]
        @controller = ResourceFull::Base.controller_for(opts[:controller])
      end
    # 
    #   def to_xml(opts={})
    #     {
    #       :resource => resource,
    #       :verb => verb,
    #       :name => name,
    #       :pattern => pattern,
    #       :action => action
    #     }.to_xml(opts.merge(:root => "route"))
    #   end
    # 
      def formatted?
        name.to_s =~ /^formatted/
      end
      
      def resource
        controller.respond_to?(:model_name) ? controller.model_name : nil
      end
    
      def resourced?
        not resource.nil?
      end
    
    end
  end
end