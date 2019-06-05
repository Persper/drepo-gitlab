# frozen_string_literal: true

module Snapshots
  class UserSnapshotSaver
    include Gitlab::DrepoImportExport::CommandLineUtil

    attr_accessor :shared
    delegate :user_dir, :snapshot_dir, :json_file, :archive_file, :avatar_file, to: :shared

    def initialize(snapshot:)
      @snapshot = snapshot
      @shared = UserSnapshotShared.new(@snapshot.user)
    end

    def save
      FileUtils.mkdir_p(snapshot_dir)

      save_json_file
      save_user_avatar

      if compress_and_save
        response = Ipfs::AddService.new(file: archive_file).execute

        if response['Hash']
          @snapshot.ipfs_path = response['Hash']
          @snapshot
        else
          raise response.to_s
        end
      else
        raise compress_and_save_error_message
      end

    ensure
      FileUtils.rm_rf(snapshot_dir)
      FileUtils.rm_f(archive_file)
    end

    def compress_and_save
      tar_czf(archive: archive_file, dir: snapshot_dir)
    end

    def save_json_file
      @snapshot.take_snapshot
      File.write(json_file, @snapshot.content.to_json)
    end

    def save_user_avatar
      avatar = @snapshot.user.avatar
      return unless avatar.exists?

      download_or_copy_upload(avatar, avatar_file)
    end

    def compress_and_save_error_message
      "Unable to save #{archive_file}"
    end
  end
end
