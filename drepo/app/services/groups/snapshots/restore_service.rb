# frozen_string_literal: true

module Groups
  module Snapshots
    class RestoreService
      RestoreError = Class.new(StandardError)

      def initialize(user, group, ipfs_path)
        @user, @group, @ipfs_path = user, group, ipfs_path
      end

      def execute
        @snapshot = Dg::GroupSnapshot.new(author: @user, group: @group)
        ::Snapshots::GroupSnapshotRestorer.new(ipfs_path: @ipfs_path, snapshot: @snapshot).restore
        @snapshot.restore!
      rescue StandardError => e
        @snapshot.reason = e.message
        @snapshot.crash!
        raise RestoreError, e
      end
    end
  end
end
