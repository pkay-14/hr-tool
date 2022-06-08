task :fix_jira_worklogs, [:from, :to] => :environment do |t, args|
  args.with_defaults(from: 1.years.ago.beginning_of_year.strftime("%d-%m-%Y"), to: Date.today.strftime("%d-%m-%Y"))

  puts "retrieving faulty worklogs"
  missing_project_worklogs = Utils::JiraLibrary::JiraWorklogLibrary.new(args[:from], args[:to]).missing_project_worklogs
  missing_issue_worklogs = Utils::JiraLibrary::JiraWorklogLibrary.new(args[:from], args[:to]).missing_issue_worklogs

  if missing_project_worklogs.present?
    merged_worklogs = missing_project_worklogs.each do |wl_date, wl_masters|
      missing_issue_worklogs[wl_date].present? ? missing_issue_worklogs[wl_date] = (missing_issue_worklogs[wl_date] | wl_masters) : missing_issue_worklogs[wl_date] = wl_masters
    end
  else
    merged_worklogs = missing_issue_worklogs
  end

  if merged_worklogs.blank?
    puts "No faulty worklogs available within #{args[:from]} and #{args[:to]}"
    puts "...please pass in different dates as arguments: [from, to]"
  else
    puts "Faulty worklogs retrieved"
    Rake::Task['jira_data_by_dates'].invoke(nil, nil, merged_worklogs)
  end
end

