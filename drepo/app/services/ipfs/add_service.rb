# frozen_string_literal: true

module Ipfs
  class AddService
    attr_accessor :params

    def initialize(params = {})
      @params = params.dup
    end

    def execute
      file = params[:file]
      return if file.nil?

      client = Ipfs::Client.new Gitlab.config.ipfs.http_api
      client.add(file)
    end
  end
end
