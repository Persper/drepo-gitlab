# frozen_string_literal: true

module Snapshots
  class GroupSnapshotSaver
    include Gitlab::DrepoImportExport::CommandLineUtil

    attr_accessor :shared
    delegate :snapshot_dir, :json_file, :archive_file, :avatar_file, to: :shared

    def initialize(snapshot:)
      @snapshot = snapshot
      @shared = GroupSnapshotShared.new(@snapshot.author)
    end

    def save
      FileUtils.mkdir_p(snapshot_dir)

      save_json_file
      save_group_avatar

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

    def save_group_avatar
      avatar = @snapshot.group.avatar
      return unless avatar.exists?

      download_or_copy_upload(avatar, avatar_file)
    end

    def compress_and_save_error_message
      "Unable to save #{archive_file}"
    end
  end
end
