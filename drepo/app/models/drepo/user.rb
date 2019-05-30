# frozen_string_literal: true

module Drepo
  module User
    extend ActiveSupport::Concern

    prepended do
      has_many :snapshots, class_name: 'Dg::Snapshot'
      has_many :created_snapshots, foreign_key: :creator_id, class_name: 'Dg::Snapshot'
    end
  end
end
