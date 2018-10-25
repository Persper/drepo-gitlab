# frozen_string_literal: true
# Group Milestones are milestones that can be shared among many projects within the same group
class GroupMilestone < GlobalMilestone
  attr_accessor :group, :milestones

  EPOCH = DateTime.parse('1970-01-01')

  def self.build_collection(group, projects, params)
    params =
      { project_ids: projects.map(&:id), state: params[:state] }

    child_milestones = MilestonesFinder.new(params).execute # rubocop: disable CodeReuse/Finder

    milestones = child_milestones.select(:id, :title).group_by(&:title).map do |title, grouped|
      milestones_relation = Milestone.where(id: grouped.map(&:id))
      new(title, milestones_relation, group)
    end

    milestones.sort_by { |milestone| milestone.due_date || EPOCH }
  end

  def self.build(group, projects, title)
    child_milestones = Milestone.of_projects(projects).where(title: title)
    return if child_milestones.blank?

    new(title, child_milestones, group)
  end

  def initialize(title, milestones, group)
    @milestones = milestones
    @milestone = milestones.find {|m| m.description.present? } || milestones.first
    @group = group
  end

  def issues_finder_params
    { group_id: group.id }
  end

  def legacy_group_milestone?
    true
  end
end
