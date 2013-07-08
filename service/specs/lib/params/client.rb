module Util
  module ClientUtil
    def create_client
      ::Client.setup(ENV['SERVICE_URI'])
    end

    module_function :create_client
  end
end