# frozen_string_literal: true

module Dg
  class Task < ApplicationRecord
    extend Gitlab::Dg::Model

    belongs_to :author, class_name: 'User'
    belongs_to :source, polymorphic: true, inverse_of: :tasks

    state_machine :state, initial: :created do
      state :created
      state :running
      state :failed
      state :success
      state :cancelled

      event :run do
        transition any - [:running] => :running
      end

      event :drop do
        transition any - [:failed] => :failed
      end

      event :succeed do
        transition any - [:success] => :success
      end

      event :cancel do
        transition any - [:cancelled] => :cancelled
      end

      before_transition [:created] => :running do |task|
        task.started_at = Time.now
      end

      before_transition any => [:success, :failed, :canceled] do |task|
        task.finished_at = Time.now
      end
    end
  end
end
