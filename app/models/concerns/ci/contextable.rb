# frozen_string_literal: true

module Ci
  ##
  # Abstract CI/CD Context interface for contexts and pipelines.
  #
  module Contextable
    extend ActiveSupport::Concern
  end
end
