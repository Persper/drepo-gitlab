class Projects::DrepoSyncsController < Projects::IssuesController
  # prepend a modified IssuableCollections for drepo Issues objects
  prepend DrepoIssuableCollections
  before_action :authenticate_user!
  before_action :set_issuables_index

  def new
    @issues = @issuables
    @commits = []
    @pipelines = []
    @total_commit_count = 5
  end
end
