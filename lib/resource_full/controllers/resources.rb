module ResourceFull
  module Controllers
    class ResourcesController < ActionController::Base
      include ResourceFull
      responds_to :xml

      protected
        def find_all_resources
          ResourceFull.all_resources
        end

        def find_resource
          ResourceFull.controller_for(params[:id].pluralize)
        end
    end
  end
end