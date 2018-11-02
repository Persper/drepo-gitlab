# frozen_string_literal: true
require 'faker'
require 'uri'
require 'benchmark'

module QA
  context :performance do
    describe 'Merge Request Performance' do
      before(:context) do
        @api_client = Runtime::API::Client.new(:gitlab)
        @group_id = create_group
        @project_id = create_project
        @RESPONSE_THRESHOLD = 1.0 #1 second
      end

      def create_request(api_endpoint)
        Runtime::API::Request.new(@api_client, api_endpoint)
      end

      def create_group
        group_name = "group_#{SecureRandom.hex(8)}"
        create_group_request = create_request("/groups")
        post create_group_request.url, name: group_name, path: group_name
        expect_status(201)
        json_body[:id]
      end

      def create_project
        project_name = "project_#{SecureRandom.hex(8)}"
        create_project_request = create_request('/projects')
        post create_project_request.url, path: project_name, name: project_name, namespace_id: @group_id
        expect_status(201)
        json_body[:id]
      end

      def create_branch
        request = create_request("/projects/#{@project_id}/repository/branches")
        post request.url, branch: 'perf-testing', ref: 'master'
        expect_status(201)
      end

      def upload_file(branch, content, commit_message, file_path, exists = false)
        request = create_request("/projects/#{@project_id}/repository/files/#{file_path}")
        if exists
          put request.url, branch: branch, content: content, commit_message: commit_message
          expect_status(200)
        else
          post request.url, branch: branch, content: content, commit_message: commit_message
          expect_status(201)
        end
      end

      def populate_data_for_mr
        content_arr = []
        5.times do |i|
          faker_line_arr = Faker::Lorem.sentences(1500)
          content =  faker_line_arr.join("\n\r")
          upload_file('master', content, "Add testfile-#{i}.md", "testfile-#{i}.md")
          content_arr[i] = faker_line_arr
        end
        create_branch
        5.times do |i|
          missed_line_array = content_arr[i].each_slice(2).map(&:first)
          content = missed_line_array.join("\n\rIm new!:D \n\r ")
          upload_file('perf-testing', content, "Update testfile-#{i}.md", "testfile-#{i}.md", true)
        end
        request = create_request("/projects/#{@project_id}/merge_requests")
        post request.url, source_branch: 'perf-testing', target_branch: 'master', title: 'My MR'
        puts json_body.to_s
        expect_status(201)
        json_body[:web_url]
      end

      it 'Create MR' do
        mr_url = populate_data_for_mr

        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.act { sign_in_using_credentials }

        visit mr_url

        Page::MergeRequest::Show.perform do |show_page|
          show_page.go_to_diffs_tab
          show_page.expand_diff
          show_page.add_comment_to_diff("Can you check this line of code?")

          expect(show_page.response_time(:comment)).to be <= @RESPONSE_THRESHOLD

          expect(show_page).to have_content("Can you check this line of code?")
          show_page.reply_to_discussion("And this syntax as well?")

          expect(show_page.response_time(:comment)).to be <= @RESPONSE_THRESHOLD
          expect(show_page).to have_content("And this syntax as well?")

          show_page.reply_to_discussion("Unresolving this discussion")
          expect(show_page.response_time(:comment)).to be <= @RESPONSE_THRESHOLD
          puts "PAGE_LOAD : " + show_page.page_load_time.to_s
        end
      end

    end
  end
end
