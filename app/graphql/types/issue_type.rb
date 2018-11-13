# frozen_string_literal: true

module Types
  class IssueType < BaseObject
    expose_permissions Types::PermissionTypes::Issue

    graphql_name 'Issue'

    field :id, GraphQL::ID_TYPE, null: false
    field :iid, GraphQL::ID_TYPE, null: false
    field :title, GraphQL::STRING_TYPE, null: false
    field :description, GraphQL::STRING_TYPE, null: true
    field :state, GraphQL::STRING_TYPE, null: false

    field :author, Types::UserType, null: false
    field :assignees, [Types::UserType], null: true

    field :labels, [Types::LabelType], null: true
    field :milestone, Types::MilestoneType, null: true

    field :due_date, Types::TimeType, null: true
    field :confidential, GraphQL::BOOLEAN_TYPE, null: false
    field :discussion_locked, GraphQL::BOOLEAN_TYPE, null: false

    field :upvotes, GraphQL::INT_TYPE, null: false
    field :downvotes, GraphQL::INT_TYPE, null: false
    field :user_notes_count, GraphQL::INT_TYPE, null: false
    field :web_url, GraphQL::STRING_TYPE, null: false

    field :closed_at, Types::TimeType, null: true

    field :created_at, Types::TimeType, null: false
    field :updated_at, Types::TimeType, null: false
  end
end
