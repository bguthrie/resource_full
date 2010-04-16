module ResourceFull
  module CoreExtensions
    module Hash
      def from_json(json)
        ActiveSupport::JSON.decode json
      end
    end
  end
end

class Hash
  extend ResourceFull::CoreExtensions::Hash
end
