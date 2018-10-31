# frozen_string_literal: true

module Ci
  class Workspace < Ci::Context
    extend Gitlab::Ci::Model

    belongs_to :project

    def commit
    end

    def sha
    end

    def short_sha
    end

    def before_sha
    end
  end
end
