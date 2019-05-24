# frozen_string_literal: true

module Gitlab
  module DrepoImportExport
    class VersionChecker
      def self.check!(*args)
        new(*args).check!
      end

      def initialize(shared:)
        @shared = shared
      end

      def check!
        version = File.open(version_file, &:readline)
        verify_version!(version)
      rescue => e
        @shared.error(e)
        false
      end

      private

      def version_file
        File.join(@shared.export_path, Gitlab::DrepoImportExport.version_filename)
      end

      def verify_version!(version)
        if different_version?(version)
          raise Gitlab::DrepoImportExport::Error.new("Import version mismatch: Required #{Gitlab::DrepoImportExport.version} but was #{version}")
        else
          true
        end
      end

      def different_version?(version)
        Gem::Version.new(version) != Gem::Version.new(Gitlab::DrepoImportExport.version)
      rescue => e
        Rails.logger.error("Import/Export error: #{e.message}")
        raise Gitlab::DrepoImportExport::Error.new('Incorrect VERSION format')
      end
    end
  end
end
