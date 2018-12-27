# frozen_string_literal: true

module Drepo
  module ImportExport
    class VersionSaver
      include Drepo::ImportExport::CommandLineUtil

      def initialize(shared:)
        @shared = shared
      end

      def save
        mkdir_p(@shared.export_path)

        File.write(version_file, Drepo::ImportExport.version, mode: 'w')
      rescue => e
        @shared.error(e)
        false
      end

      private

      def version_file
        File.join(@shared.export_path, Drepo::ImportExport.version_filename)
      end
    end
  end
end
