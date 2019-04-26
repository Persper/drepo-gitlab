class Projects::DrepoSyncsController < Projects::ApplicationController
  include ExtractsPath
  include RendersCommits
  include DiffHelper
  include RendersNotes

  prepend_before_action(only: [:new]) { params[:ref] ||= 'master' }
  before_action :authenticate_user!, except: [:drepo_refs]
  before_action :assign_ref_vars, only: [:new]
  before_action :validate_ref!, only: [:new]
  before_action :set_commits, only: [:new]

  def new
    Apartment::Tenant.switch 'drepo_project_pending' do
      @project = Project.find(@project.id)
      @issues_total_count = @project.issues.count
      @issues = @project.issues.includes(:labels, :assignees, :events).page(params[:page]).load # rubocop:disable CodeReuse/ActiveRecord
    end

    respond_to do |format|
      format.html
      format.atom { render layout: 'xml.atom' }

      format.json do
        pager_json(
          'projects/drepo_syncs/commits/_commits',
          @commits.size,
          project: @project,
          ref: @ref)
      end
    end
  end

  # show the issue
  def drepo_issue
    Apartment::Tenant.switch 'drepo_project_pending' do
      @project = Project.find(@project.id)
      @issuable = @noteable = @issue = Issue.includes(includes_options).find_by(iid: params[:id]) # rubocop:disable CodeReuse/ActiveRecord
      @note = @project.notes.new(noteable: @issuable)
      # @issuable_sidebar = serializer.represent(@issue, serializer: 'sidebar')
    end

    respond_to do |format|
      format.html { render 'projects/drepo_syncs/issues/show' }
    end
  end

  def drepo_refs
    find_refs = params['find']

    find_branches = true
    find_tags = true
    find_commits = true

    unless find_refs.nil?
      find_branches = find_refs.include?('branches')
      find_tags = find_refs.include?('tags')
      find_commits = find_refs.include?('commits')
    end

    options = {}

    set_snapshot

    if find_branches
      branches = @snapshot&.branches&.map { |b| b['name'] }.sort
      index = branches.index('master')
      if index && index > 0
        branches[index] = branches[0]
        branches[0] = 'master'
      end

      if params['search'].present?
        branches.select! { |b| b.include? params['search'] }
      end

      options['Branches'] = branches
    end

    if find_tags
      tags = @snapshot&.tags&.map { |t| t['name'] }.sort

      if params['search'].present?
        tags.select! { |t| t.include? params['search'] }
      end

      options['Tags'] = tags
    end

    # If reference is commit id - we should add it to branch/tag selectbox
    ref = Addressable::URI.unescape(params[:ref])
    if find_commits && ref && options.flatten(2).exclude?(ref) && ref =~ /\A[0-9a-zA-Z]{6,52}\z/
      options['Commits'] = [ref]
    end

    render json: options.to_json
  end

  def drepo_commit
    Apartment::Tenant.switch 'drepo_project_pending' do
      @noteable = @commit ||= @project.commit_by(oid: params[:id]).tap do |commit|
        # preload author and their status for rendering
        commit&.author&.status
      end

      define_note_vars

      opts = diff_options
      opts[:ignore_whitespace_change] = true if params[:format] == 'diff'

      @diffs = @commit.diffs(opts)
      @notes_count = @commit.notes.count
    end

    respond_to do |format|
      format.html { render 'projects/drepo_syncs/commits/show' }
    end
  end

  private

  def includes_options
    [:labels, :assignees, :milestone, :events, :project, project: :namespace]
  end

  def serializer
    IssueSerializer.new(current_user: current_user, project: @issue.project)
  end

  def validate_ref!
    render_404 unless valid_ref?(@ref)
  end

  def set_commits
    render_404 unless @path.empty? || request.format == :atom || @repository.blob_at(@commit.id, @path) || @repository.tree(@commit.id, @path).entries.present?
    @limit, @offset = (params[:limit] || 40).to_i, (params[:offset] || 0).to_i
    search = params[:commits_search]
    get_ref_revision

    @commits =
      if search.present?
        @repository.find_commits_by_message(search, @ref_revision, @path, @limit, @offset)
      else
        @repository.commits(@ref_revision, path: @path, limit: @limit, offset: @offset)
      end

    @commits = @commits.with_pipeline_status
    @commits = set_commits_for_rendering(@commits)
  end

  def set_snapshot
    project = Project.find(@project.id)
    @snapshot = project&.snapshots&.last
  end

  def get_ref_revision
    set_snapshot
    all_ref_revision_pairs = (@snapshot&.branches || []).concat(@snapshot&.tags || [])
    all_ref_revision_pairs.each do |pair|
      if pair['name'] == @ref
        @ref_revision = pair['sha']
        break
      end
    end

    @ref_revision ||= @ref
  end

  def commit
    @noteable = @commit ||= @project.commit_by(oid: params[:id]).tap do |commit|
      # preload author and their status for rendering
      commit&.author&.status
    end
  end

  def define_note_vars
    @noteable = @commit
    @note = @project.build_commit_note(commit)

    @new_diff_note_attrs = {
      noteable_type: 'Commit',
      commit_id: @commit.id
    }

    @grouped_diff_discussions = @commit.grouped_diff_discussions
    @discussions = @commit.discussions

    # if merge_request_iid = params[:merge_request_iid]
    #   @merge_request = MergeRequestsFinder.new(current_user, project_id: @project.id).find_by(iid: merge_request_iid)
    #
    #   if @merge_request
    #     @new_diff_note_attrs.merge!(
    #       noteable_type: 'MergeRequest',
    #       noteable_id: @merge_request.id
    #     )
    #
    #     merge_request_commit_notes = @merge_request.notes.where(commit_id: @commit.id).inc_relations_for_view
    #     merge_request_commit_diff_discussions = merge_request_commit_notes.grouped_diff_discussions(@commit.diff_refs)
    #     @grouped_diff_discussions.merge!(merge_request_commit_diff_discussions) do |line_code, left, right|
    #       left + right
    #     end
    #   end
    # end

    @notes = (@grouped_diff_discussions.values.flatten + @discussions).flat_map(&:notes)
    @notes = prepare_notes_for_rendering(@notes, @commit)
  end
end
