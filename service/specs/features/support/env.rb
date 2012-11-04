$:.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))

require 'active_support/core_ext'
require 'client'
require 'util'
require 'base64'

Before do
  @client = Util::ClientUtil.create_client
end
