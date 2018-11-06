# frozen_string_literal: true

class ClusterAncestorsFinder
  def initialize(clusterable, user)
    @clusterable = clusterable
    @user = user
  end

  def execute
    clusterable.clusters + ancestor_clusters
  end

  private

  attr_reader :clusterable, :user

  def ancestor_clusters
    Gitlab::GroupHierarchy.new(base_query).base_and_ancestors.flat_map do |group|
      group.clusters
    end
  end

  def base_query
    case clusterable
    when Project
      Group.joins(:projects).where(projects: { id: clusterable.id })
    when Group
      Group.where(id: clusterable.parent_id)
    end
  end
end
