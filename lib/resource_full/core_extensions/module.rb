module ResourceFull
  module CoreExtensions
    module Module
      def simple_name
        name.split("::").last
      end
    end
  end
end

Module.send(:include, ResourceFull::CoreExtensions::Module)
