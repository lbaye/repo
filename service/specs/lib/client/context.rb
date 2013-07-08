module Client
  class Context
    ATTRS = [:uri, :params, :http_method, :headers]

    attr_accessor *ATTRS

    def initialize(uri, http_method = :get)
      self.uri         = uri
      self.http_method = http_method
      self.headers     = { }
      self.params      = { }
    end

    ATTRS.each do |attr|
      class_eval <<-CODE
          def set_#{attr}(p)
            self.#{attr} = p
            self
          end
      CODE
    end

    def response
      @response ||= _create_response
    end

    def body
      self.response.body
    end

    def code
      self.response.code
    end

    def content_type
      self.response.content_type
    end

    def json
      unless self.response.body.nil?
        JSON.load(self.response.body)
      else
        {}
      end
    end

    private
    def _create_response
      uri  = URI.parse(self.uri)
      http = Net::HTTP.new(uri.host, uri.port)

      case self.http_method
        when :get
          _get(uri, http)

        when :post
          _post(uri, http)

        when :delete
          _delete(uri, http)

        when :put
          _put(uri, http)
      end
    end

    def _get(uri, http)
      path    = "#{uri.request_uri}?#{self.params.map { |k, v| "k=#{CGI.escape(v)}" }.join('&')}"
      request = Net::HTTP::Get.new(path, self.headers)
      http.request(request)
    end

    def _delete(uri, http)
      path    = "#{uri.request_uri}?#{self.params.map { |k, v| "k=#{CGI.escape(v)}" }.join('&')}"
      request = Net::HTTP::Delete.new(path, self.headers)
      http.request(request)
    end

    def _post(uri, http)
      request = Net::HTTP::Post.new(uri.request_uri, self.headers)
      request.set_form_data(self.params)
      http.request(request)
    end

    def _put(uri, http)
      request = Net::HTTP::Put.new(uri.request_uri, self.headers)
      request.set_form_data(self.params)
      http.request(request)
    end
  end
end