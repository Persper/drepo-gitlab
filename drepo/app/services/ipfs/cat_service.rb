# frozen_string_literal: true

module Ipfs
  class CatService
    attr_accessor :params

    def initialize(params = {})
      @params = params.dup
    end

    def execute
      ipfs_path = params[:ipfs_path]
      return if ipfs_path.nil?

      file = params[:file]
      client = Ipfs::Client.new Gitlab.config.ipfs.http_api

      if file
        client.cat_to_file ipfs_path, file
      else
        client.cat ipfs_path
      end
    end
  end
end
