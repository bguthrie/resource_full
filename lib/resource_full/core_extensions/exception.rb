class Exception
  def to_xml(opts={})
    xml = opts[:builder] || Builder::XmlMarkup.new
    
    xml.errors {
      xml.error "#{self.class}: #{self.to_s}"
      xml.error self.backtrace
    }
  end
end