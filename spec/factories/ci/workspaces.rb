FactoryBot.define do
  factory :ci_workspace, class: Ci::Workspace do
    project factory: :project
  end
end
