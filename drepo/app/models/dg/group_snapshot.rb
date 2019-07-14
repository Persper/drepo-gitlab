# frozen_string_literal: true

module Dg
  class GroupSnapshot < ApplicationRecord
    extend Gitlab::Dg::Model

    belongs_to :author, class_name: 'User'
    belongs_to :group

    state_machine :state, initial: :created do
      state :exported
      state :restored
      state :failed

      event :export do
        transition created: :exported
      end

      event :crash do
        transition [:created] => :failed
      end

      event :restore do
        transition [:created] => :restored
      end

      after_transition any => any do |snapshot|
        snapshot.state_updated_at = Time.now
      end
    end

    def take_snapshot
      self.content = {
        name: group.name,
        path: group.path,
        full_path: group.full_path,
        descendants_and_projects: descendants_and_projects,
        group_members: take_group_members
      }
    end

    def restore_content!
      return unless content

      the_content = HashWithIndifferentAccess.new(content)

      full_path = the_content[:full_path]

      unless full_path == group.full_path
        errors.add(:base, 'Wrong group to restore')
        raise ActiveModel::ValidationError.new(self)
      end

      restore_group_members(the_content)

      group.save!
    end

    def restore_avatar!(avatar_file)
      group.avatar = File.open(avatar_file)
      group.save!
    end

    def descendants_and_projects
      group.all_projects.map(&:full_path) + group.descendants.map(&:full_path)
    end

    def take_group_members
      members = []
      group.group_members.active_without_invites_and_requests.find_each do |member|
        # next unless member.user&.is_username_verified
        members << {
          access_level: member.access_level,
          drepo_username: member.user.username,
          expires_at: member.expires_at
        }
      end
      members
    end

    def restore_group_members(the_content)
      members = the_content[:group_members]
      return unless members.is_a?(Array)

      members.each do |member|
        user = User.find_by(username: member.drepo_username, is_username_verified: true)
        next unless user

        group_member = GroupMember.find_or_create_by(user: user)

        group_member_params = {
          access_level: member[:access_level],
          drepo_username: member[:user.username],
          expires_at: member[:expires_at],
          user: user
        }
        group_member.update!(group_member_params)
      end
    end
  end
end
