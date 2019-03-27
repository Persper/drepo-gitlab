# frozen_string_literal: true

module Drepo
  module User
    extend ActiveSupport::Concern

    prepended do
      has_many :snapshots
    end
  end
end
