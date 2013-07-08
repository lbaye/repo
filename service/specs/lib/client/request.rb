module Client
  METHODS = %w{get post put delete head}

  class Request
    attr_accessor :service_uri

    def initialize(service_uri)
      @service_uri = service_uri
    end

    METHODS.each do |method|
      class_eval <<-CODE
          def #{method}(uri)
            Context.new("\#{self.service_uri}\#{uri}", :#{method})
          end
      CODE
    end
  end
end