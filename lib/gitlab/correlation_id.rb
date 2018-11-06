# frozen_string_literal: true

module Gitlab
  module CorrelationId
    def self.use_id(correlation_id, &blk)
      ids << correlation_id

      begin
        yield
      ensure
        ids.unshift
      end
    end

    def self.current_id
      ids.last
    end

    private

    def self.ids
      Thread.current[:correlation_id] ||= []
    end
  end
end
