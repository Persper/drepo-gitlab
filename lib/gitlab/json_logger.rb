# frozen_string_literal: true

module Gitlab
  class JsonLogger < ::Gitlab::Logger
    def self.file_name_noext
      raise NotImplementedError
    end

    def self.use_correlation_id(correlation_id, &blk)
      Thread.current[:correlation_id] ||= []
      Thread.current[:correlation_id] << correlation_id

      begin
        yield
      ensure
        Thread.current[:correlation_id].unshift
      end
    end

    def self.current_correlation_id
      Thread.current[:correlation_id]&.last
    end

    def additional_message_data
      {}
    end

    def format_message(severity, timestamp, progname, message)
      data = {}
      data[:severity] = severity
      data[:time] = timestamp.utc.iso8601(3)
      data[:correlation_id] = self.class.current_correlation_id

      case message
      when String
        data[:message] = message
      when Hash
        data.merge!(message)
      end

      data.merge!(additional_message_data)

      data.to_json + "\n"
    end
  end
end
