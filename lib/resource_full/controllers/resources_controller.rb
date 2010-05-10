module ResourceFull
  module Controllers
    class ResourcesController < ActionController::Base
      include ResourceFull
      responds_to :xml, :only => [ :read ]
      
      def index_xml
        render :xml => find_all_resources.to_xml(:root => "resources")
      end
      
      def show_xml
        render :xml => find_resource.to_xml
      rescue ResourceFull::ResourceNotFound => e
        render :xml => e.to_xml, :status => :not_found
      end

      protected
        def find_all_resources
          ResourceFull.all_resources
        end

        def find_resource
          ResourceFull.controller_for(params[:id])
        end
    end
  end
end