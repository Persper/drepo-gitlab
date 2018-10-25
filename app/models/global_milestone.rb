# frozen_string_literal: true
# Global Milestones are milestones that can be shared across multiple projects
class GlobalMilestone
  include Milestoneish

  STATE_COUNT_HASH = { opened: 0, closed: 0, all: 0 }.freeze

  attr_accessor :milestone
  alias_attribute :name, :title

  delegate :title, :state, :due_date, :start_date, :participants, :project, :group, to: :milestone

  def to_hash
    {
       name: title,
       title: title,
       group_name: group&.full_name,
       project_name: project&.full_name
    }
  end

  def for_display
    @milestone
  end

  def self.build_collection(projects, params)
    items = Milestone.of_projects(projects.map(&:id))
                .reorder_by_due_date_asc
                .order_by_name_asc

    Milestone.filter_by_state(items, params[:state]).map { |m| new(m) }
  end

  # necessary for legacy milestones
  def self.build(projects, title)
    milestones = Milestone.of_projects(projects).where(title: title)
    return if milestones.blank?

    new(milestones.first)
  end

  def self.states_count(projects, group = nil)
    legacy_group_milestones_count = legacy_group_milestone_states_count(projects)
    group_milestones_count = group_milestones_states_count(group)

    legacy_group_milestones_count.merge(group_milestones_count) do |k, legacy_group_milestones_count, group_milestones_count|
      legacy_group_milestones_count + group_milestones_count
    end
  end

  def self.group_milestones_states_count(group)
    return STATE_COUNT_HASH unless group

    params = { group_ids: [group.id], state: 'all' }

    relation = MilestonesFinder.new(params).execute # rubocop: disable CodeReuse/Finder
    grouped_by_state = relation.reorder(nil).group(:state).count

    {
      opened: grouped_by_state['active'] || 0,
      closed: grouped_by_state['closed'] || 0,
      all: grouped_by_state.values.sum
    }
  end

  # Counts the legacy group milestones which must be grouped by title
  def self.legacy_group_milestone_states_count(projects)
    return STATE_COUNT_HASH unless projects

    params = { project_ids: projects.map(&:id), state: 'all' }

    relation = MilestonesFinder.new(params).execute # rubocop: disable CodeReuse/Finder
    project_milestones_by_state = relation.reorder(nil).group(:state).count

    {
      opened: project_milestones_by_state['active'] || 0,
      closed: project_milestones_by_state['closed'] || 0,
      all: project_milestones_by_state.values.sum
    }
  end

  def initialize(milestone)
    @milestone = milestone
  end

  def safe_title
    title.to_slug.normalize.to_s
  end

  def active?
    state == 'active'
  end

  def closed?
    state == 'closed'
  end

  def issues
    @issues ||= Issue.of_milestones(milestone.id).includes(:project, :assignees, :labels)
  end

  def merge_requests
    @merge_requests ||= MergeRequest.of_milestones(milestone.id).includes(:target_project, :assignee, :labels)
  end

  def labels
    @labels ||= GlobalLabel.build_collection(milestone.labels).sort_by!(&:title)
  end

  def milestoneish_ids
    milestone.id
  end
end
