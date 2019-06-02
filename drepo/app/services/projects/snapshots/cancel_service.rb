# frozen_string_literal: true

module Projects
  module Snapshots
    class CancelService < BaseService
      CancelError = Class.new(StandardError)

      def initialize(user, params)
        @current_user, @params = user, params.dup
      end

      def execute
        # rubocop: disable CodeReuse/ActiveRecord
        @snapshot = Dg::ProjectSnapshot.find_by!(params)
        # rubocop: enable CodeReuse/ActiveRecord

        @snapshot.cancel!
      end
    end
  end
end
