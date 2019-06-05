# frozen_string_literal: true

module Drepo
  module User
    extend ActiveSupport::Concern

    prepended do
      has_many :user_snapshots, class_name: 'Dg::UserSnapshot'
      has_many :project_snapshots, class_name: 'Dg::ProjectSnapshot'
      has_many :created_project_snapshots, foreign_key: :creator_id, class_name: 'Dg::ProjectSnapshot'
    end
  end
end
