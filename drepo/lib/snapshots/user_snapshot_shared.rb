# frozen_string_literal: true

module Snapshots
  class UserSnapshotShared
    MAX_RETRIES = 3

    def initialize(user)
      @user = user
    end

    def user_dir
      @user_dir ||= File.join(Gitlab.config.ipfs.storage_path, @user.username)
    end

    def snapshot_dir
      @snapshot_dir ||= File.join(user_dir, hex)
    end

    def json_file
      @json_file ||= File.join(snapshot_dir, 'content.json')
    end

    def archive_file
      @archive_file ||= File.join(user_dir, "#{hex}.tar.gz")
    end

    def avatar_file
      @avatar_file ||= File.join(snapshot_dir, 'avatar.jpg')
    end

    def hex
      @hex ||= SecureRandom.hex
    end
  end
end
