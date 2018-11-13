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

      IssuesFinder.new(context[:current_user], args).execute
        .preload(:assignees, :labels, :notes, :timelogs, :project, :author, :closed_by)
        .limit(args[:limit])
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
