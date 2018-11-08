# frozen_string_literal: true

module Resolvers
  class IssuesResolver < BaseResolver
    extend ActiveSupport::Concern

    argument :search, GraphQL::STRING_TYPE,
              required: false
    argument :limit, GraphQL::INT_TYPE,
              required: false,
              default_value: 10

    type Types::IssueType, null: true

    alias_method :project, :object

    # rubocop: disable CodeReuse/ActiveRecord
    def resolve(**args)
      args[:project_id] = project.id
      args[:per_page] = 2

      IssuesFinder.new(context[:current_user], args).execute.limit(args[:limit])
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
