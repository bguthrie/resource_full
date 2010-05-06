module ResourceFull
  module CoreExtensions
    module Module
      def simple_name
        name.demodulize
      end
    end
  end
end

class Module
  include ResourceFull::CoreExtensions::Module
end
