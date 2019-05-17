# frozen_string_literal: true

module Gitlab
  module DrepoImportExport
    class VersionSaver
      include Gitlab::DrepoImportExport::CommandLineUtil

      def initialize(shared:)
        @shared = shared
      end

      def save
        mkdir_p(@shared.export_path)

        File.write(version_file, Gitlab::DrepoImportExport.version, mode: 'w')
      rescue => e
        @shared.error(e)
        false
      end

      private

      def version_file
        File.join(@shared.export_path, Gitlab::DrepoImportExport.version_filename)
      end
    end
  end
end
