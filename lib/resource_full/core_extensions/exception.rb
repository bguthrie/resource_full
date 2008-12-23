module ResourceFull
  module CoreExtensions
    module Exception
      def to_xml(opts={})
        xml = opts[:builder] || Builder::XmlMarkup.new
    
        xml.errors {
          xml.error "#{self.class}: #{self.to_s}"
          xml.error self.backtrace
        }
      end
    end
  end
end

class Exception
  include ResourceFull::CoreExtensions::Exception
end