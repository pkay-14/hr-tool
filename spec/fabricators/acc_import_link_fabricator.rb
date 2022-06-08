Fabricator(:import_link, from: Acc::ImportLink) do
  redmine_id {rand(10)}
  master_id { "MASTER##{Time.now.to_i}"}
end

Fabricator(:import_link_json, from: Acc::ImportLink) do
  redmine_id 1
  master_id "JSON IMPORT MASTER"
end

Fabricator(:test_link, from: Acc::ImportLink) do
  redmine_id 2
  master_id TEST_MASTER
end

Fabricator(:test_link2, from: Acc::ImportLink) do
  redmine_id 2
  master_id TEST_MASTER
  tax_group 2
end

Fabricator(:test_link3, from: Acc::ImportLink) do
  redmine_id 2
  master_id TEST_MASTER
  tax_group 3
end

Fabricator(:test_uat, from: Acc::ImportLink) do
  redmine_id 3
  master_id TEST_UAT
end
