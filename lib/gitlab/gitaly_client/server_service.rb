# frozen_string_literal: true

module Gitlab
  module GitalyClient
    # Meant for extraction of server data, and later maybe to perform misc task
    #
    # Not meant for connection logic, look in Gitlab::GitalyClient
    class ServerService
      def initialize(storage)
        @storage = storage
      end

      def info
        GitalyClient.call(@storage, :server_service, :server_info, Gitaly::ServerInfoRequest.new, timeout: GitalyClient.fast_timeout)
      end
    end
  end
end
