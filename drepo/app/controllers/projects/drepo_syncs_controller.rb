class Projects::DrepoSyncsController < Projects::IssuesController
  include ExtractsPath
  include RendersCommits

  prepend_before_action(only: [:new]) { params[:ref] ||= 'master' }
  before_action :authenticate_user!
  before_action :assign_ref_vars, except: [:commits_root, :drepo_issue]
  before_action :validate_ref!, except: [:commits_root, :drepo_issue]
  before_action :set_commits, except: [:commits_root, :drepo_issue]

  def new
    Apartment::Tenant.switch 'drepo_project_pending' do
      @project = Project.find(@project.id)
      @issues_total_count = @project.issues.count
      @issues = @project.issues.includes(:labels, :assignees, :events).page(params[:page]).load
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
      @issue = Issue.includes(includes_options).find_by(iid: params[:id])
      #@issuable_sidebar = serializer.represent(@issue, serializer: 'sidebar') # rubocop:disable Gitlab/ModuleWithInstanceVariables
    end

    respond_to do |format|
      format.html { render 'projects/drepo_syncs/issues/show' }
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

    @commits =
      if search.present?
        @repository.find_commits_by_message(search, @ref, @path, @limit, @offset)
      else
        @repository.commits(@ref, path: @path, limit: @limit, offset: @offset)
      end

    @commits = @commits.with_pipeline_status
    @commits = set_commits_for_rendering(@commits)
  end
end
