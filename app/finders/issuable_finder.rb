# frozen_string_literal: true

# IssuableFinder
#
# Used to filter Issues and MergeRequests collections by set of params
#
# Arguments:
#   klass - actual class like Issue or MergeRequest
#   current_user - which user use
#   params:
#     scope: 'created_by_me' or 'assigned_to_me' or 'all'
#     state: 'opened' or 'closed' or 'locked' or 'all'
#     group_id: integer
#     project_id: integer
#     milestone_title: string
#     author_id: integer
#     assignee_id: integer or 'None' or 'Any'
#     search: string
#     label_name: string
#     sort: string
#     non_archived: boolean
#     iids: integer[]
#     my_reaction_emoji: string
#     created_after: datetime
#     created_before: datetime
#     updated_after: datetime
#     updated_before: datetime
#     use_cte_for_search: boolean
#
class IssuableFinder
  prepend FinderWithCrossProjectAccess
  include FinderMethods
  include CreatedAtFilter

  requires_cross_project_access unless: -> { project? }

  # This is used as a common filter for None / Any
  FILTER_NONE = 'none'.freeze
  FILTER_ANY = 'any'.freeze

  # This is accepted as a deprecated filter and is also used in unassigning users
  NONE = '0'.freeze

  attr_accessor :current_user, :params

  def self.scalar_params
    @scalar_params ||= %i[
      assignee_id
      assignee_username
      author_id
      author_username
      authorized_only
      group_id
      iids
      label_name
      milestone_title
      my_reaction_emoji
      non_archived
      project_id
      scope
      search
      sort
      state
      include_subgroups
      use_cte_for_search
    ]
  end

  def self.array_params
    @array_params ||= { label_name: [], iids: [], assignee_username: [] }
  end

  def self.valid_params
    @valid_params ||= scalar_params + [array_params]
  end

  def initialize(current_user, params = {})
    @current_user = current_user
    @params = params
  end

  def execute
    items = init_collection
    items = filter_items(items)

    # This has to be last as we may use a CTE as an optimization fence by
    # passing the use_cte_for_search param
    # https://www.postgresql.org/docs/current/static/queries-with.html
    items = by_search(items)

    sort(items)
  end

  def filter_items(items)
    items = by_project(items)
    items = by_scope(items)
    items = by_created_at(items)
    items = by_updated_at(items)
    items = by_state(items)
    items = by_group(items)
    items = by_assignee(items)
    items = by_author(items)
    items = by_non_archived(items)
    items = by_iids(items)
    items = by_milestone(items)
    items = by_label(items)
    by_my_reaction_emoji(items)
  end

  def row_count
    Gitlab::IssuablesCountForState.new(self).for_state_or_opened(params[:state])
  end

  # We often get counts for each state by running a query per state, and
  # counting those results. This is typically slower than running one query
  # (even if that query is slower than any of the individual state queries) and
  # grouping and counting within that query.
  #
  # rubocop: disable CodeReuse/ActiveRecord
  def count_by_state
    count_params = params.merge(state: nil, sort: nil)
    finder = self.class.new(current_user, count_params)
    counts = Hash.new(0)

    # Searching by label includes a GROUP BY in the query, but ours will be last
    # because it is added last. Searching by multiple labels also includes a row
    # per issuable, so we have to count those in Ruby - which is bad, but still
    # better than performing multiple queries.
    #
    # This does not apply when we are using a CTE for the search, as the labels
    # GROUP BY is inside the subquery in that case, so we set labels_count to 1.
    labels_count = label_names.any? ? label_names.count : 1
    labels_count = 1 if use_cte_for_search?

    finder.execute.reorder(nil).group(:state).count.each do |key, value|
      counts[count_key(key)] += value / labels_count
    end

    counts[:all] = counts.values.sum

    counts.with_indifferent_access
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def group
    return @group if defined?(@group)

    @group =
      if params[:group_id].present?
        Group.find(params[:group_id])
      else
        nil
      end
  end

  def project?
    params[:project_id].present?
  end

  def project
    return @project if defined?(@project)

    project = Project.find(params[:project_id])
    project = nil unless Ability.allowed?(current_user, :"read_#{klass.to_ability_name}", project)

    @project = project
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def projects(items = nil)
    return @projects = project if project?

    projects =
      if current_user && params[:authorized_only].presence && !current_user_related?
        current_user.authorized_projects
      elsif group
        finder_options = { include_subgroups: params[:include_subgroups], only_owned: true }
        GroupProjectsFinder.new(group: group, current_user: current_user, options: finder_options).execute # rubocop: disable CodeReuse/Finder
      else
        ProjectsFinder.new(current_user: current_user).execute # rubocop: disable CodeReuse/Finder
      end

    @projects = projects.with_feature_available_for_user(klass, current_user).reorder(nil)
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def search
    params[:search].presence
  end

  def milestones?
    params[:milestone_title].present?
  end

  def milestones
    return @milestones if defined?(@milestones)

    @milestones =
      if milestones?
        if project?
          group_id = project.group&.id
          project_id = project.id
        end

        group_id = group.id if group

        search_params =
          { title: params[:milestone_title], project_ids: project_id, group_ids: group_id }

        MilestonesFinder.new(search_params).execute # rubocop: disable CodeReuse/Finder
      else
        Milestone.none
      end
  end

  def labels?
    params[:label_name].present?
  end

  def filter_by_no_label?
    labels? && params[:label_name].include?(Label::None.title)
  end

  def labels
    return @labels if defined?(@labels)

    @labels =
      if labels? && !filter_by_no_label?
        LabelsFinder.new(current_user, project_ids: projects, title: label_names).execute(skip_authorization: true) # rubocop: disable CodeReuse/Finder
      else
        Label.none
      end
  end

  def assignee_id?
    params[:assignee_id].present?
  end

  def assignee_username?
    params[:assignee_username].present?
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def assignee
    return @assignee if defined?(@assignee)

    @assignee =
      if assignee_id?
        User.find_by(id: params[:assignee_id])
      elsif assignee_username?
        User.find_by_username(params[:assignee_username])
      else
        nil
      end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def author_id?
    params[:author_id].present? && params[:author_id] != NONE
  end

  def author_username?
    params[:author_username].present? && params[:author_username] != NONE
  end

  def no_author?
    # author_id takes precedence over author_username
    params[:author_id] == NONE || params[:author_username] == NONE
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def author
    return @author if defined?(@author)

    @author =
      if author_id?
        User.find_by(id: params[:author_id])
      elsif author_username?
        User.find_by_username(params[:author_username])
      else
        nil
      end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  private

  def init_collection
    klass.all
  end

  def count_key(value)
    Array(value).last.to_sym
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def by_scope(items)
    return items.none if current_user_related? && !current_user

    case params[:scope]
    when 'created_by_me', 'authored'
      items.where(author_id: current_user.id)
    when 'assigned_to_me'
      items.assigned_to(current_user)
    else
      items
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def by_updated_at(items)
    items = items.updated_after(params[:updated_after]) if params[:updated_after].present?
    items = items.updated_before(params[:updated_before]) if params[:updated_before].present?

    items
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def by_state(items)
    case params[:state].to_s
    when 'closed'
      items.closed
    when 'merged'
      items.respond_to?(:merged) ? items.merged : items.closed
    when 'opened'
      items.opened
    when 'locked'
      items.where(state: 'locked')
    else
      items
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def by_group(items)
    # Selection by group is already covered by `by_project` and `projects`
    items
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def by_project(items)
    items =
      if project?
        items.of_projects(projects).references_project
      elsif projects
        items.merge(projects.reorder(nil)).join_project
      else
        items.none
      end

    items
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def use_cte_for_search?
    return false unless search
    return false unless Gitlab::Database.postgresql?
    return false unless Feature.enabled?(:use_cte_for_group_issues_search, default_enabled: true)

    params[:use_cte_for_search]
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def by_search(items)
    return items unless search

    if use_cte_for_search?
      cte = Gitlab::SQL::RecursiveCTE.new(klass.table_name)
      cte << items

      items = klass.with(cte.to_arel).from(klass.table_name)
    end

    items.full_search(search)
  end
  # rubocop: enable CodeReuse/ActiveRecord

  # rubocop: disable CodeReuse/ActiveRecord
  def by_iids(items)
    params[:iids].present? ? items.where(iid: params[:iids]) : items
  end
  # rubocop: enable CodeReuse/ActiveRecord

  # rubocop: disable CodeReuse/ActiveRecord
  def sort(items)
    # Ensure we always have an explicit sort order (instead of inheriting
    # multiple orders when combining ActiveRecord::Relation objects).
    params[:sort] ? items.sort_by_attribute(params[:sort], excluded_labels: label_names) : items.reorder(id: :desc)
  end
  # rubocop: enable CodeReuse/ActiveRecord

  # rubocop: disable CodeReuse/ActiveRecord
  def by_assignee(items)
    if filter_by_no_assignee?
      items.where(assignee_id: nil)
    elsif filter_by_any_assignee?
      items.where('assignee_id IS NOT NULL')
    elsif assignee
      items.where(assignee_id: assignee.id)
    elsif assignee_id? || assignee_username? # assignee not found
      items.none
    else
      items
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def filter_by_no_assignee?
    # Assignee_id takes precedence over assignee_username
    [NONE, FILTER_NONE].include?(params[:assignee_id].to_s.downcase) || params[:assignee_username].to_s == NONE
  end

  def filter_by_any_assignee?
    params[:assignee_id].to_s.downcase == FILTER_ANY
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def by_author(items)
    if author
      items = items.where(author_id: author.id)
    elsif no_author?
      items = items.where(author_id: nil)
    elsif author_id? || author_username? # author not found
      items = items.none
    end

    items
  end
  # rubocop: enable CodeReuse/ActiveRecord

  # rubocop: disable CodeReuse/ActiveRecord
  def by_milestone(items)
    if milestones?
      if filter_by_no_milestone?
        items = items.left_joins_milestones.where(milestone_id: [-1, nil])
      elsif filter_by_any_milestone?
        items = items.any_milestone
      elsif filter_by_upcoming_milestone?
        upcoming_ids = Milestone.upcoming_ids_by_projects(projects(items))
        items = items.left_joins_milestones.where(milestone_id: upcoming_ids)
      elsif filter_by_started_milestone?
        items = items.left_joins_milestones.where('milestones.start_date <= NOW()')
      else
        items = items.with_milestone(params[:milestone_title])
      end
    end

    items
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def filter_by_no_milestone?
    # Accepts `No Milestone` for compatibility
    params[:milestone_title].to_s.downcase == FILTER_NONE || params[:milestone_title] == Milestone::None.title
  end

  def filter_by_any_milestone?
    # Accepts `Any Milestone` for compatibility
    params[:milestone_title].to_s.downcase == FILTER_ANY || params[:milestone_title] == Milestone::Any.title
  end

  def filter_by_upcoming_milestone?
    params[:milestone_title] == Milestone::Upcoming.name
  end

  def filter_by_started_milestone?
    params[:milestone_title] == Milestone::Started.name
  end

  def by_label(items)
    return items unless labels?

    items =
      if filter_by_no_label?
        items.without_label
      else
        items.with_label(label_names, params[:sort])
      end

    items
  end

  def by_my_reaction_emoji(items)
    if params[:my_reaction_emoji].present? && current_user
      items =
        if filter_by_no_reaction?
          items.not_awarded(current_user)
        elsif filter_by_any_reaction?
          items.awarded(current_user)
        else
          items.awarded(current_user, params[:my_reaction_emoji])
        end
    end

    items
  end

  def filter_by_no_reaction?
    params[:my_reaction_emoji].to_s.downcase == FILTER_NONE
  end

  def filter_by_any_reaction?
    params[:my_reaction_emoji].to_s.downcase == FILTER_ANY
  end

  def label_names
    if labels?
      params[:label_name].is_a?(String) ? params[:label_name].split(',') : params[:label_name]
    else
      []
    end
  end

  def by_non_archived(items)
    params[:non_archived].present? ? items.non_archived : items
  end

  def current_user_related?
    scope = params[:scope]
    scope == 'created_by_me' || scope == 'authored' || scope == 'assigned_to_me'
  end
end
