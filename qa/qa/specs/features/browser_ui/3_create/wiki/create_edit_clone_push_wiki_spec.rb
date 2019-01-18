# frozen_string_literal: true

module QA
  context 'Create' do
    describe 'Wiki management' do
      def login
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.act { sign_in_using_credentials }
      end

      def validate_content(content)
        expect(page).to have_content('Wiki was successfully updated')
        expect(page).to have_content(/#{content}/)
      end

      before do
        login
      end

      # Failure reported: https://gitlab.com/gitlab-org/quality/nightly/issues/24
      it 'user creates, edits, clones, and pushes to the wiki', :quarantine do
        wiki = Resource::Wiki.fabricate! do |resource|
          resource.title = 'Home'
          resource.content = '# My First Wiki Content'
          resource.message = 'Update home'
        end

        validate_content('My First Wiki Content')

        Page::Project::Wiki::Edit.act { go_to_edit_page }
        Page::Project::Wiki::New.perform do |page|
          page.set_content("My Second Wiki Content")
          page.save_changes
        end

        validate_content('My Second Wiki Content')

        Resource::Repository::WikiPush.fabricate! do |push|
          push.wiki = wiki
          push.file_name = 'Home.md'
          push.file_content = '# My Third Wiki Content'
          push.commit_message = 'Update Home.md'
        end
        Page::Project::Menu.act { click_wiki }

        expect(page).to have_content('My Third Wiki Content')
      end
    end
  end
end
