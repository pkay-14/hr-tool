Fabricator(:project, from: Acc::Project) do
  name { "Test project ##{Time.now.to_i}" }
  uat_acceptor { Fabricate(:import_link) }
  redmine_id { rand(100) }
  prosperworks_account_id { rand(100) }
end

Fabricator(:import_project, from: Acc::Project) do
  name "Test Import Project"
  uat_acceptor_id 1
  redmine_id 1
  prosperworks_account_id 10101
end


Fabricator(:test_project, from: Acc::Project) do
  name "Test Project"
  redmine_id 1
  prosperworks_account_id 10101
end