module Client
  def setup(service_uri)
    Request.new(service_uri)
  end

  module_function :setup
end