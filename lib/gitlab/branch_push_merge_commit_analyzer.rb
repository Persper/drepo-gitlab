# frozen_string_literal: true

module Gitlab
  # Analyse a graph of commits from a push to a branch,
  # for each commit, analyze that if it is the head of a merge request,
  # then what should its merge_commit be, relative to the branch.
  #
  # A----->B----->C----->D   target branch
  # |             ^
  # |             |
  # +-->E----->F--+          merged branch
  #     |     ^
  #     |     |
  #     +->G--+
  #
  # (See merge-commit-analyze-after branch in gitlab-test)
  #
  # Assuming
  # - A is already in remote
  # - B~D are all in its own branch with its own merge request, targeting the target branch
  #
  # When D is finally pushed to the target branch,
  # what are the merge commits for all the other merge requests?
  #
  # We can walk backwards from the HEAD commit D,
  # and find status of its parents.
  # First we determine if commit belongs to the target branch (i.e. A, B, C, D),
  # and then determine its merge commit.
  #
  # +--------+----------------+--------------+
  # | Commit | Target branch? | Merge commit |
  # +--------+----------------+--------------+
  # | D      | Y              | D            |
  # +--------+----------------+--------------+
  # | C      | Y              | C            |
  # +--------+----------------+--------------+
  # | F      |                | C            |
  # +--------+----------------+--------------+
  # | B      | Y              | B            |
  # +--------+----------------+--------------+
  # | E      |                | C            |
  # +--------+----------------+--------------+
  # | G      |                | C            |
  # +--------+----------------+--------------+
  #
  # By examining the result, it can be said that
  #
  # - If commit belongs to target branch, its merge commit is itself.
  # - Otherwise, the merge commit is the same as its child's merge commit.
  #
  class BranchPushMergeCommitAnalyzer
    class CommitDecorator < SimpleDelegator
      attr_accessor :merge_commit
      attr_writer :target_branch # boolean

      def target_branch?
        @target_branch
      end

      # @param child_commit [CommitDecorator]
      # @param first_parent [Boolean] whether `self` is the first parent of `child_commit`
      def set_merge_commit(child_commit, first_parent:)
        # If child commit belongs to target branch, its first parent is assumed to belong to target branch.
        # This assumption is correct most of the time, but there are exception cases which can't be solved.
        # See https://stackoverflow.com/a/49754723/474597
        @target_branch = (first_parent && child_commit.target_branch?)

        @merge_commit = target_branch? ? self : child_commit.merge_commit
      end
    end

    def initialize(commits)
      @commits = commits.reverse

      analyze
    end

    def get_merge_commit(id)
      get_commit(id).merge_commit.id
    end

    private

    def analyze
      head_commit = get_commit(@commits.first.id)
      head_commit.target_branch = true
      head_commit.merge_commit = head_commit

      # Analyzing a commit requires its child commit be analyzed first,
      # which is the case here since commits are ordered from child to parent.
      id_to_commit.each_value do |commit|
        analyze_parents(commit)
      end
    end

    def analyze_parents(commit)
      commit.parent_ids.each.with_index do |parent_commit_id, i|
        parent_commit = get_commit(parent_commit_id)

        next if parent_commit.nil? # parent commit may not be part of new commits

        parent_commit.set_merge_commit(commit, first_parent: i == 0)
      end
    end

    def get_commit(id)
      id_to_commit[id]
    end

    def id_to_commit
      @id_to_commit ||= @commits.each_with_object({}) do |commit, hash|
        hash[commit.id] = CommitDecorator.new(commit)
      end
    end
  end
end
