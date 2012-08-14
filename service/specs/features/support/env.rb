$:.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))

require 'client'
require 'util'

Before do
  @client = Util::ClientUtil.create_client
end