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

      to_file = params[:to_file]
      client = Ipfs::Client.new Gitlab.config.ipfs.http_api

      if to_file
        client.cat_to_file ipfs_path, to_file
      else
        client.cat ipfs_path
      end
    end
  end
end
