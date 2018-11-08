# frozen_string_literal: true
# Dashboard Group Milestones are milestones that allow us to pull more info out for the UI that the Milestone object doesn't allow for
class DashboardGroupMilestone < GlobalMilestone
  extend ::Gitlab::Utils::Override

  attr_reader :group_name

  override :initialize
  def initialize(milestone)
    super

    @group_name = milestone.group.full_name
  end

  def self.build_collection(groups)
    Milestone.of_groups(groups.select(:id))
             .reorder_by_due_date_asc
             .order_by_name_asc
             .active
             .map { |m| new(m) }
  end

  override :group_milestone?
  def group_milestone?
    @milestone.group_milestone?
  end

  def group
    @milestone.group
  end

  def iid
    @milestone.iid
  end
end
