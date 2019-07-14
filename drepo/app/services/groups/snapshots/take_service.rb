# frozen_string_literal: true

module Groups
  module Snapshots
    class TakeService
      TakeError = Class.new(StandardError)

      def initialize(user, group)
        @user = user
        @group = group
      end

      def execute
        @snapshot = Dg::GroupSnapshot.new(author: @user, group: @group)

        ::Snapshots::GroupSnapshotSaver.new(snapshot: @snapshot).save

        @snapshot.export!
      rescue StandardError => e
        @snapshot.reason = e.message
        @snapshot.crash!
        raise TakeError, e
      end
    end
  end
end
