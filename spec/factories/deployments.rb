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

    # Legacy deployment rows do not have a value in status column.
    # In spec, we set this status by default for retaining original intention of tests
    after(:create) do |deployment, evaluator|
      deployment.update_column(:status, nil)
    end

    trait :review_app do
      sha { TestEnv::BRANCH_SHA['pages-deploy'] }
      ref 'pages-deploy'
    end

    trait :created do
      after(:create) do |deployment, evaluator|
        deployment.update_column(:status, Deployment.state_machine.states['created'].value)
      end
    end

    trait :running do
      after(:create) do |deployment, evaluator|
        deployment.update_column(:status, Deployment.state_machine.states['running'].value)
      end
    end

    trait :success do
      finished_at { Time.now }

      after(:create) do |deployment, evaluator|
        deployment.update_column(:status, Deployment.state_machine.states['success'].value)
        Ci::DeploymentSuccessWorker.new.perform(deployment)
      end
    end

    trait :failed do
      finished_at { Time.now }

      after(:create) do |deployment, evaluator|
        deployment.update_column(:status, Deployment.state_machine.states['failed'].value)
      end
    end

    trait :canceled do
      finished_at { Time.now }

      after(:create) do |deployment, evaluator|
        deployment.update_column(:status, Deployment.state_machine.states['canceled'].value)
      end
    end
  end
end
