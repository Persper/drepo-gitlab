# frozen_string_literal: true

module Types
  class UserType < BaseObject
    graphql_name 'User'

    field :id, GraphQL::ID_TYPE, null: false
    field :name, GraphQL::STRING_TYPE, null: false
    field :username, GraphQL::STRING_TYPE, null: false
    field :avatar_url, GraphQL::STRING_TYPE, null: false
    field :web_url, GraphQL::STRING_TYPE, null: false
  end
end
