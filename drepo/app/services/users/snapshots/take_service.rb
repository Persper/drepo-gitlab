# frozen_string_literal: true

module Users
  module Snapshots
    class TakeService
      TakeError = Class.new(StandardError)

      def initialize(user)
        @user = user
      end

      def execute
        @snapshot = Dg::UserSnapshot.new(user: @user)

        ::Snapshots::UserSnapshotSaver.new(snapshot: @snapshot).save

        @snapshot.export!
      rescue StandardError => e
        @snapshot.reason = e.message
        @snapshot.crash!
        raise TakeError, e
      end
    end
  end
end
