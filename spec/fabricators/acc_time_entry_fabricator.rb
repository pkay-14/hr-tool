Fabricator(:time_entry, from: Acc::TimeEntry) do
  month Date.today.month
  year Date.today.year
  master_id TEST_MASTER
end



