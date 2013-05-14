# coding: utf-8

module BitbucketApiExtension
  class PullRequestDetail < BitbucketApiExtension::PullRequest

    attribute :from_user_or_team_name, String
    attribute :from_repository_name, String
    attribute :from_branch_name, String
    attribute :from_commit_id, String
    attribute :to_user_or_team_name, String
    attribute :to_repository_name, String
    attribute :to_branch_name, String
  end
end
