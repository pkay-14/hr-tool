class Account
  include Mongoid::Document

  field :hipchat_url, type: String
  field :redmine_login, type: String
  field :redmine_password, type: String
  field :email_login, type: String
  field :email_password, type: String
  field :git_login, type: String
  field :git_password, type: String
  field :seafile_login, type: String
  field :seafile_password, type: String

  embedded_in :user

end
