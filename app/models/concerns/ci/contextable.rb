# frozen_string_literal: true

module Ci
  ##
  # Abstract CI/CD Workspace interface for workspaces and pipelines.
  #
  module Contextable
    extend ActiveSupport::Concern
  end
end
