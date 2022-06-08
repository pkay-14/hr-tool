class AddOnboardingToJiraIssues < ActiveRecord::Migration
  def change
    add_column :jira_issues, :onboarding, :boolean
  end
end
