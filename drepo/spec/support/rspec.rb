require_relative "helpers/stub_ipfs"

RSpec.configure do |config|
  config.include StubIpfs
end
