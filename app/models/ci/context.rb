# frozen_string_literal: true

module Ci
  class Context < ActiveRecord::Base
    self.abstract_class = true

    def predefined_variables
      Gitlab::Ci::Variables::Collection.new
    end

    def commit
      raise NotImplementedError
    end

    def sha
      raise NotImplementedError
    end

    def short_sha
      raise NotImplementedError
    end

    def before_sha
      raise NotImplementedError
    end
  end
end
