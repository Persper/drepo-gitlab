# frozen_string_literal: true

module Drepo
  module Group
    extend ActiveSupport::Concern

    prepended do
      has_many :group_snapshots, class_name: 'Dg::GroupSnapshot'
    end
  end
end
