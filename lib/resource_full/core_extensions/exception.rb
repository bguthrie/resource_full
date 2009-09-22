module ResourceFull
  module CoreExtensions
    module Exception
      def to_xml(opts={})
        xml = opts[:builder] || Builder::XmlMarkup.new

        xml.errors {
          xml.error self.to_s
          xml.error self.backtrace if opts[:include_backtrace] == true
        }
      end

      def to_json(opts={})
        {"error" => {:text => self.to_s,
                     :backtrace => self.backtrace}}.to_json
      end
    end
  end
end

class Exception
  include ResourceFull::CoreExtensions::Exception
end
