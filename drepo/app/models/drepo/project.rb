# frozen_string_literal: true

module Drepo
  module Project
    extend ActiveSupport::Concern

    prepended do
      has_many :snapshots, as: :target, dependent: :destroy
    end

    def create_snapshot(current_user)
      params = {
        target_id: self.id,
        target_type: self.class.name
      }
      Snapshots::CreateService.new(current_user, params).execute
    end
  end
end
