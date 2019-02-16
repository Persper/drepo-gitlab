class Projects::DrepoSyncsController < Projects::ApplicationController
  before_action :authenticate_user!

  def new
    @commits = ["xxx"]
    @pipelines = []
    @total_commit_count = 5
  end
end
