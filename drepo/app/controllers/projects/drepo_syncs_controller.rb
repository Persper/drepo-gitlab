class Projects::DrepoSyncsController < Projects::IssuesController
  # prepend a modified IssuableCollections for drepo Issues objects
  prepend DrepoIssuableCollections
  include ExtractsPath
  include RendersCommits

  prepend_before_action(only: [:new]) { params[:ref] ||= 'master' }
  before_action :authenticate_user!
  before_action :set_issuables_index
  before_action :assign_ref_vars, except: :commits_root
  before_action :validate_ref!, except: :commits_root
  before_action :set_commits, except: :commits_root

  def new
    @issues = @issuables

    respond_to do |format|
      format.html
      format.atom { render layout: 'xml.atom' }

      format.json do
        pager_json(
          'projects/commits/_commits',
          @commits.size,
          project: @project,
          ref: @ref)
      end
    end
  end

  private

  def validate_ref!
    render_404 unless valid_ref?(@ref)
  end

  def set_commits
    render_404 unless @path.empty? || request.format == :atom || @repository.blob_at(@commit.id, @path) || @repository.tree(@commit.id, @path).entries.present?
    @limit, @offset = (params[:limit] || 20).to_i, (params[:offset] || 0).to_i
    search = params[:search]

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
