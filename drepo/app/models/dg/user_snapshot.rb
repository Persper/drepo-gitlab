# frozen_string_literal: true

module Dg
  class UserSnapshot < ApplicationRecord
    extend Gitlab::Dg::Model

    belongs_to :user

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
        created_at: user.created_at,
        updated_at: user.updated_at,
        name: user.name,
        skype: user.skype,
        linkedin: user.linkedin,
        twitter: user.twitter,
        bio: user.bio,
        username: user.username,
        website_url: user.website_url,
        public_email: user.public_email,
        preferred_language: user.preferred_language
      }
    end

    def restore_content!
      return unless content

      the_content = HashWithIndifferentAccess.new(content)

      user.update!({
                     name: the_content[:name],
                     skype: the_content[:skype],
                     linkedin: the_content[:linkedin],
                     twitter: the_content[:twitter],
                     bio: the_content[:bio],
                     username: the_content[:username],
                     website_url: the_content[:website_url],
                     public_email: the_content[:public_email],
                     preferred_language: the_content[:preferred_language]
                   })
    end

    def restore_avatar!(avatar_file)
      user.avatar = File.open(avatar_file)
      user.save!
    end
  end
end
