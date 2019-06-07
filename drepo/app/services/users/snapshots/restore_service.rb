# frozen_string_literal: true

module Users
  module Snapshots
    class RestoreService
      RestoreError = Class.new(StandardError)

      def initialize(user, ipfs_path)
        @user, @ipfs_path = user, ipfs_path
      end

      def execute
        @snapshot = Dg::UserSnapshot.new(user: @user)
        ::Snapshots::UserSnapshotRestorer.new(ipfs_path: @ipfs_path, snapshot: @snapshot).restore
        @snapshot.restore!
      rescue StandardError => e
        @snapshot.reason = e.message
        @snapshot.crash!
        raise RestoreError, e
      end
    end
  end
end
