Fabricator(:active_account, from: Acc::Account) do
  owner_id TEST_OWNER
  acc_type AccountingService::ACCOUNT_ACTIVE
  description "Some active test account"
  debit_balance 0
  credit_balance 0
end

Fabricator(:passive_account) do

end

Fabricator(:active_passive_account) do

end