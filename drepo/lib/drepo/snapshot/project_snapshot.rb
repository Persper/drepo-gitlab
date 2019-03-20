# frozen_string_literal: true

module Drepo
  module Snapshot
    class ProjectSnapshot < BaseSnapshot
      # rubocop:disable CodeReuse/ActiveRecord
      attr_accessor :project, :user_ids

      def initialize(options)
        super(options)
        @project = Project.find(root_id)
        @user_ids = []
      end

      def create
        copy_project
        copy_labels
        copy_milestones
        copy_issues
        copy_merge_requests
        copy_snippets

        copy_notes
        copy_events

        copy_project_members

        copy_releases

        # @user_ids will be collected in the above functions
        copy_users
      end

      def copy_project
        connection.query(generate_snapshot_sql(Project.where(id: root_id)))
      end

      def copy_labels
        label_ids = connection.query(generate_snapshot_sql(Label.where(project_id: root_id)))

        # don't copy namespace labels
        # namespace = project.namespace
        # namespaces = [namespace] + namespace.ancestors
        # label_ids += connection.query(generate_snapshot_sql(Label.where(group_id: namespaces)))

        # label_links, only copy project labels associations
        connection.execute(generate_snapshot_sql(LabelLink.where(label_id: label_ids)))
        # copy label priority
        connection.execute(generate_snapshot_sql(LabelPriority.where(label_id: label_ids)))

        delay_after('Issue', 'MergeRequest') do
          # copy resource label event
          u_ids = connection.query(generate_snapshot_sql(
                                     ResourceLabelEvent.where(label_id: label_ids),
                                     returning: 'user_id'))
          collect_user_ids(u_ids)
        end

        label_ids
      end

      def copy_milestones
        connection.query(generate_snapshot_sql(Milestone.where(project_id: root_id)))
      end

      def copy_issues
        # Issue, events copied in #copy_events
        result = connection.query(generate_snapshot_sql(
                                    Issue.where(project_id: root_id),
                                    returning: %w(id author_id updated_by_id last_edited_by_id closed_by_id)))
        issue_ids, issue_user_ids = result.each_with_object([[], []]) do |element, two_arr|
          two_arr[0] << element[0]
          two_arr[1] << element[1]
          two_arr[1] << element[2]
          two_arr[1] << element[3]
          two_arr[1] << element[4]
        end
        collect_user_ids(issue_user_ids)

        connection.execute(generate_snapshot_sql(MergeRequestsClosingIssues.where(issue_id: issue_ids)))

        issue_assignee_user_ids = connection.query(generate_snapshot_sql(
                                                     IssueAssignee.where(issue_id: issue_ids),
                                                     returning: 'user_id'))
        collect_user_ids(issue_assignee_user_ids)

        # Issuable, lable_links copied in #copy_labels, notes copied in #copy_notes
        connection.execute(generate_snapshot_sql(Issue::Metrics.where(issue_id: issue_ids)))
        copy_award_emoji(issue_ids, 'Issue')
        # TODO: add todos

        # Subscribable
        # TODO: add subscription

        # Spammable
        copy_user_agent_detail(issue_ids, 'Issue')

        # run delay
        run_delay('Issue')

        issue_ids
      end

      def copy_merge_requests
        # MergeRequest, events copied in #copy_events
        result = connection.query(
          generate_snapshot_sql(
            MergeRequest.where(target_project_id: root_id),
            returning: %w(id author_id updated_by_id merge_user_id assignee_id last_edited_by_id)))
        mr_ids, mr_user_ids = result.each_with_object([[], []]) do |element, two_arr|
          two_arr[0] << element[0]
          two_arr[1] << element[1]
          two_arr[1] << element[2]
          two_arr[1] << element[3]
          two_arr[1] << element[4]
          two_arr[1] << element[5]
        end
        collect_user_ids(mr_user_ids)

        diff_ids = connection.query(generate_snapshot_sql(MergeRequestDiff.where(merge_request_id: mr_ids)))
        connection.execute(generate_snapshot_sql(MergeRequestDiffFile.where(merge_request_diff_id: diff_ids)))
        connection.execute(generate_snapshot_sql(MergeRequestDiffCommit.where(merge_request_diff_id: diff_ids)))
        connection.execute(generate_snapshot_sql(MergeRequestsClosingIssues.where(merge_request_id: mr_ids)))

        # Issuable, lable_links copied in #copy_labels, notes copied in #copy_notes
        connection.execute(generate_snapshot_sql(MergeRequest::Metrics.where(merge_request_id: mr_ids)))
        copy_award_emoji(mr_ids, 'MergeRequest')
        # TODO: add todos

        # Subscribable
        # TODO: add subscription

        # Spammable
        copy_user_agent_detail(mr_ids, 'MergeRequest')

        # run delay
        run_delay('MergeRequest')

        mr_ids
      end

      def copy_snippets
        result = connection.query(generate_snapshot_sql(
                                    Snippet.where(project_id: root_id), returning: %w(id author_id)))
        snippet_ids, u_ids = result.each_with_object([[], []]) do |element, two_arr|
          two_arr[0] << element[0]
          two_arr[1] << element[1]
        end
        collect_user_ids(u_ids)

        copy_award_emoji(snippet_ids, 'Snippet')

        # Spammable
        copy_user_agent_detail(snippet_ids, 'Snippet')

        snippet_ids
      end

      def copy_notes
        result = connection.query(generate_snapshot_sql(Note.where(project_id: root_id), returning: %w(id author_id)))
        note_ids, u_ids = result.each_with_object([[], []]) do |element, two_arr|
          two_arr[0] << element[0]
          two_arr[1] << element[1]
        end
        collect_user_ids(u_ids)

        copy_award_emoji(note_ids, 'Note')

        note_ids
      end

      def copy_events
        result = connection.query(generate_snapshot_sql(Event.where(project_id: root_id), returning: %w(id author_id)))
        event_ids, u_ids = result.each_with_object([[], []]) do |element, two_arr|
          two_arr[0] << element[0]
          two_arr[1] << element[1]
        end
        collect_user_ids(u_ids)

        connection.query(generate_snapshot_sql(PushEventPayload.where(event_id: event_ids)))
        event_ids
      end

      def copy_project_members
        # Users have different abilities depending on the access level they have in a
        # particular group or project. If a user is both in a group's project and the
        # project itself, the highest permission level is used.
        # Here we drop down group members as project members
        project_members = MembersFinder.new(project, nil).execute(include_descendants: true)
        result = connection.query(generate_snapshot_sql(
                                    Member.none,
                                    select_statement: project_members.to_sql,
                                    returning: %w(id user_id)))
        member_ids, u_ids = result.each_with_object([[], []]) do |element, two_arr|
          two_arr[0] << element[0]
          two_arr[1] << element[1]
        end
        collect_user_ids(u_ids)

        member_ids
      end

      def copy_user_agent_detail(subject_id, subject_type)
        connection.query(generate_snapshot_sql(
                           UserAgentDetail.where(subject_id: subject_id, subject_type: subject_type)))
      end

      def copy_award_emoji(awardable_id, awardable_type)
        result = connection.query(generate_snapshot_sql(
                                    AwardEmoji.where(awardable_id: awardable_id, awardable_type: awardable_type),
                                    returning: %w(id user_id)))
        award_emoji_ids, u_ids = result.each_with_object([[], []]) do |element, two_arr|
          two_arr[0] << element[0]
          two_arr[1] << element[1]
        end
        collect_user_ids(u_ids)

        award_emoji_ids
      end

      def copy_releases
        result = connection.query(generate_snapshot_sql(
                                    Release.where(project_id: root_id), returning: %w(id author_id)))
        release_ids, u_ids = result.each_with_object([[], []]) do |element, two_arr|
          two_arr[0] << element[0]
          two_arr[1] << element[1]
        end
        collect_user_ids(u_ids)

        # release links
        connection.query(generate_snapshot_sql(Releases::Link.where(release_id: release_ids)))

        release_ids
      end

      def copy_users
        column_names = User.column_names
        insert_column_names = column_names.join(',')
        select_column_names = column_names.map { |c| "users.#{c}" }.join(',')
        on_conflict_do = column_names.inject("ON CONFLICT (id) DO UPDATE SET ") do |statement, name|
          statement + "#{name}=excluded.#{name},"
        end
        on_conflict_do = on_conflict_do.strip[0..-2]
        sql = %Q{
          INSERT INTO #{to_schema}.users (#{insert_column_names},#{extend_insert_columns('users')})
            (SELECT DISTINCT #{select_column_names},users.created_at,users.updated_at,#{drepo_id}
            FROM #{from_schema}.users
            WHERE #{from_schema}.users.id IN (#{@user_ids.join(',')}))
          #{on_conflict_do};
        }
        puts sql
        connection.execute(sql)
      end

      def collect_user_ids(ids)
        ids.flatten!
        @user_ids += ids
        @user_ids.uniq!
        @user_ids.compact!
      end

      def user_association_tables
        %w(issues notes events resource_label_events merge_requests award_emoji snippets members releases)
      end

      def all_tables
        %w(projects milestones labels users issues notes events push_event_payloads
           label_links resource_label_events label_priorities merge_requests merge_request_diffs
           merge_request_diff_files merge_request_diff_commits user_agent_details
           merge_requests_closing_issues award_emoji snippets members releases)
      end

      def project_association_tables
        %w(milestones labels issues notes events label_priorities merge_requests snippets members releases)
      end
      # rubocop:enable CodeReuse/ActiveRecord
    end
  end
end
