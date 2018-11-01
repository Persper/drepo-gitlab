FactoryBot.define do
  factory :deployment, class: Deployment do
    sha '97de212e80737a608d939f648d959671fb0a0142'
    ref 'master'
    tag false
    user nil
    project nil
    deployable factory: :ci_build
    environment factory: :environment

    after(:build) do |deployment, evaluator|
      deployment.project ||= deployment.environment.project
      deployment.user ||= deployment.project.creator

      unless deployment.project.repository_exists?
        allow(deployment.project.repository).to receive(:create_ref)
      end
    end

    trait :review_app do
      sha { TestEnv::BRANCH_SHA['pages-deploy'] }
      ref 'pages-deploy'
    end

    trait :running do
      status { Deployment.state_machine.states['running'].value }
    end

    trait :success do
      status { Deployment.state_machine.states['success'].value }
      finished_at { Time.now }
    end

    trait :failed do
      status { Deployment.state_machine.states['failed'].value }
      finished_at { Time.now }
    end

    trait :canceled do
      status { Deployment.state_machine.states['canceled'].value }
      finished_at { Time.now }
    end

    # This trait hooks the state maechine's events
    trait :succeed do
      after(:create) do |deployment, evaluator|
        deployment.succeed!
      end
    end
  end
end
