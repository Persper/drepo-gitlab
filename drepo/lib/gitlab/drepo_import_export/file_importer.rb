# frozen_string_literal: true

module Gitlab
  module DrepoImportExport
    class FileImporter
      include Gitlab::DrepoImportExport::CommandLineUtil

      MAX_RETRIES = 8
      IGNORED_FILENAMES = %w(. ..).freeze

      def self.import(*args)
        new(*args).import
      end

      def initialize(project:, archive_file:, shared:)
        @project = project
        @archive_file = archive_file
        @shared = shared
      end

      def import
        mkdir_p(@shared.export_path)
        mkdir_p(@shared.archive_path)

        remove_symlinks
        copy_archive

        wait_for_archived_file do
          decompress_archive
        end
      rescue => e
        @shared.error(e)
        false
      ensure
        remove_import_file
        remove_symlinks
      end

      private

      # Exponentially sleep until I/O finishes copying the file
      def wait_for_archived_file
        MAX_RETRIES.times do |retry_number|
          break if File.exist?(@archive_file)

          sleep(2**retry_number)
        end

        yield
      end

      def decompress_archive
        result = untar_zxf(archive: @archive_file, dir: @shared.export_path)

        raise Projects::ImportService::Error.new("Unable to decompress #{@archive_file} into #{@shared.export_path}") unless result

        result
      end

      def copy_archive
        @archive_file = File.join(@shared.archive_path, Gitlab::DrepoImportExport.export_filename(project: @project))

        download_file_from_ipfs
      end

      def remove_symlinks
        extracted_files.each do |path|
          FileUtils.rm(path) if File.lstat(path).symlink?
        end

        true
      end

      def remove_import_file
        FileUtils.rm_rf(@archive_file)
      end

      def extracted_files
        Dir.glob("#{@shared.export_path}/**/*", File::FNM_DOTMATCH).reject { |f| IGNORED_FILENAMES.include?(File.basename(f)) }
      end

      def download_file_from_ipfs
        cat_params = {
          ipfs_path: @project.import_source,
          to_file: @archive_file
        }

        unless Ipfs::CatService.new(cat_params).execute
          raise Projects::ImportService::Error.new("Unable to download file #{@project.import_source} from IPFS")
        end
      end
    end
  end
end
