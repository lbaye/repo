$:.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))

require 'active_support/core_ext'
require 'client'
require 'util'

Before do
  @client = Util::ClientUtil.create_client
end