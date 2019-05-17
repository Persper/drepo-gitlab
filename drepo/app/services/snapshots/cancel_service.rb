# frozen_string_literal: true

module Snapshots
  class CancelService < BaseService
    CancelError = Class.new(StandardError)

    def initialize(user, params)
      @current_user, @params = user, params.dup
    end

    def execute
      target_klass = params[:target_type].constantize

      unless Dg::Snapshot::TARGET_TYPES.value? target_klass
        raise CreateError, "Snapshot target_type must be included in #{Dg::Snapshot::TARGET_TYPES.values}"
      end

      # rubocop: disable CodeReuse/ActiveRecord
      @snapshot = Dg::Snapshot.find_by!(params)
      # rubocop: enable CodeReuse/ActiveRecord

      @snapshot.cancel!
    end
  end
end
