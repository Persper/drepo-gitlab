# frozen_string_literal: true

module Gitlab
  class FileAccessJsonLogger < Gitlab::JsonLogger
    def self.file_name_noext
      'file_access_json'
    end
  end
end
