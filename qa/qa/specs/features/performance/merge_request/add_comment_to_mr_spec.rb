# frozen_string_literal: true
require 'faker'
require 'uri'
require 'benchmark'

module QA
  context :performance do
    describe 'merge request' do
      let(:api_client) do
         Runtime::API::Client.new(:gitlab)
       end
      let(:response_threshold) { 270 } # milliseconds
      let(:page_load_threshold) { 5000 } # milliseconds
      let(:project) do
        Resource::Project.fabricate! do |resource|
          resource.name = 'perf-test-project'
        end
      end

      def create_request(api_endpoint)
        Runtime::API::Request.new(api_client, api_endpoint)
      end

      def push_new_file(branch, content, commit_message, file_path, exists = false)
        request = create_request("/projects/#{project.id}/repository/files/#{file_path}")
        if exists
          put request.url, branch: branch, content: content, commit_message: commit_message
          expect_status(200)
        else
          post request.url, branch: branch, content: content, commit_message: commit_message
          expect_status(201)
        end
      end

      def create_branch(branch_name)
        request = create_request("/projects/#{project.id}/repository/branches")
        post request.url, branch: branch_name, ref: 'master'
        expect_status(201)
      end

      def populate_data_for_mr
        content_arr = []

        20.times do |i|
          faker_line_arr = Faker::Lorem.sentences(1500)
          content = faker_line_arr.join("\n\r")
          push_new_file('master', content, "Add testfile-#{i}.md", "testfile-#{i}.md")
          content_arr[i] = faker_line_arr
        end

        create_branch("perf-testing")

        20.times do |i|
          missed_line_array = content_arr[i].each_slice(2).map(&:first)
          content = missed_line_array.join("\n\rIm new!:D \n\r ")
          push_new_file('perf-testing', content, "Update testfile-#{i}.md", "testfile-#{i}.md", true)
        end

      end

      def create_merge_request
        request = create_request("/projects/#{project.id}/merge_requests")
        post request.url, source_branch: 'perf-testing', target_branch: 'master', title: 'My MR'
        expect_status(201)
        json_body[:web_url]
      end

      it 'user adds comment to mr' do
        populate_data_for_mr
        mr_url = create_merge_request

        samples_arr = []
        apdex_score = 0
        page_load_time = 0

        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.act { sign_in_using_credentials }

        visit mr_url

        Page::MergeRequest::Show.perform do |show_page|
          show_page.go_to_diffs_tab
          show_page.expand_diff
          5.times do |i|
            show_page.add_comment_to_diff("Can you check this line of code?", i)
            samples_arr.push(show_page.response_time(:comment))
          end
          apdex_score = show_page.apdex(samples_arr, response_threshold)
          page_load_time = show_page.page_load_time
        end

        expect(page_load_time < page_load_threshold).to be true
        expect((apdex_score >= 0.5) && (apdex_score <= 1.0)).to be true
      end

    end
  end
end
