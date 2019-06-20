# frozen_string_literal: true

module Gitlab
  module DrepoImportExport
    class Saver
      include Gitlab::DrepoImportExport::CommandLineUtil

      def self.save(*args)
        new(*args).save
      end

      def initialize(project:, shared:, params:)
        @project = project
        @shared = shared
        @params = HashWithIndifferentAccess.new(params)
        @snapshot = ::Dg::ProjectSnapshot.find(@params[:project_snapshot_id])
      end

      def save
        if compress_and_save
          remove_export_path

          Rails.logger.info("Saved project export #{archive_file}")

          save_upload
          save_ipfs
        else
          @shared.error(Gitlab::DrepoImportExport::Error.new(error_message))
          false
        end
      rescue => e
        @shared.error(e)
        false
      ensure
        remove_archive
        remove_export_path
      end

      private

      def compress_and_save
        tar_czf(archive: archive_file, dir: @shared.export_path)
      end

      def remove_export_path
        FileUtils.rm_rf(@shared.export_path)
      end

      def remove_archive
        FileUtils.rm_rf(@shared.archive_path)
      end

      def archive_file
        @archive_file ||= File.join(@shared.archive_path, Gitlab::DrepoImportExport.export_filename(project: @project))
      end

      def save_upload
        upload = ::Dg::ProjectSnapshotUpload.find_or_initialize_by(project_snapshot: @snapshot)

        File.open(archive_file) { |file| upload.export_file = file }

        upload.save!
      end

      def save_ipfs
        @snapshot.ipfs_file = Ipfs::AddService.new(file: archive_file).execute
        @snapshot.export!
      rescue StandardError => e
        @snapshot.reason = e.message
        @snapshot.crash!
      end

      def error_message
        "Unable to save #{archive_file} into #{@shared.export_path}."
      end
    end
  end
end
