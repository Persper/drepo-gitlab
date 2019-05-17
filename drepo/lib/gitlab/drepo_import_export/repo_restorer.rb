# frozen_string_literal: true

module Gitlab
  module DrepoImportExport
    class RepoRestorer
      include Gitlab::DrepoImportExport::CommandLineUtil

      def initialize(project:, shared:, path_to_bundle:)
        @project = project
        @path_to_bundle = path_to_bundle
        @shared = shared
      end

      def restore
        return true unless File.exist?(@path_to_bundle)

        @project.repository.create_from_bundle(@path_to_bundle)
      rescue => e
        @shared.error(e)
        false
      end
    end
  end
end
