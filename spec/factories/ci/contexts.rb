FactoryBot.define do
  factory :ci_context, class: Ci::Context do
    project factory: :project
  end
end
