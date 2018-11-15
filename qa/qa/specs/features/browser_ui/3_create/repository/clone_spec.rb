# frozen_string_literal: true

module QA
  context 'Create' do
    describe 'Git clone over HTTP', :ldap_no_tls do
      let(:location) do
        Page::Project::Show.act do
          choose_repository_clone_http
          repository_location
        end
      end

      before do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.act { sign_in_using_credentials }

        project = Resource::Project.fabricate! do |scenario|
          scenario.name = 'project-with-code'
          scenario.description = 'project for git clone tests'
        end
        project.visit!

        Git::Repository.perform do |repository|
          repository.uri = location.uri
          repository.use_default_credentials

          repository.act do
            clone
            configure_identity('GitLab QA', 'root@gitlab.com')
            commit_file('test.rb', 'class Test; end', 'Add Test class')
            commit_file('README.md', '# Test', 'Add Readme')
            push_changes
          end
        end
      end

      it 'user performs a deep clone' do
        Git::Repository.perform do |repository|
          repository.uri = location.uri
          repository.use_default_credentials

          repository.act { clone }

          expect(repository.commits.size).to eq 2
        end
      end

      it 'user performs a shallow clone' do
        Git::Repository.perform do |repository|
          repository.uri = location.uri
          repository.use_default_credentials

          repository.act { shallow_clone }

          expect(repository.commits.size).to eq 1
          expect(repository.commits.first).to include 'Add Readme'
        end
      end
    end
  end
end
