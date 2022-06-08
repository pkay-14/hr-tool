class JiraController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :check_subdomain

  def webhook
    Utils::JiraLibrary::JiraManager.new(webhook_data: webhook_params).handle_webhook if token_valid?
    head :ok
  end

  private

  def token_valid?
    webhook_params[:token] == 'c858b35605e2a16455e4'
  end

  def webhook_params
    params.permit(:webhookEvent, :issue_event_type_name, :project_id, :token,
                  worklog: [:self, :id, :started, :timeSpentSeconds, :issueId, author: [:accountId]],
                  project: [:self, :id, :name],
                  issue: [:self, :id],
                  user: [:self, :accountId, :emailAddress])
  end

end
