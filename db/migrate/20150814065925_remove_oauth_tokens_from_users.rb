# rubocop:disable all
class RemoveOauthTokensFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :github_access_token, :string
    remove_column :users, :gitlab_access_token, :string
    remove_column :users, :bitbucket_access_token, :string
    remove_column :users, :bitbucket_access_token_secret, :string
  end
end
