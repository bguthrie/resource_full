module ResourceFull
  module CoreExtensions
    module Module
      def simple_name
        name.split("::").last
      end
    end
  end
end

class Module
  include ResourceFull::CoreExtensions::Module
end
