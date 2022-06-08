require "rails_helper"


RSpec.describe Acc::TimeEntryImporter do

  before :all do
    Fabrication.manager.load_definitions
  end

  it "imports TimeEntries from Redmine correctly" do

    filename = "#{Rails.root}/spec/files/time_entry.json"

    project = Fabricate(:import_project)
    user = Fabricate(:import_link_json)


    expect(Acc::TimeEntryImporter.import(filename)).to be(true)
    expect(Acc::TimeEntry.count).to be_equal(1)
    expect(project.time_entries.count).to be_equal(1)
    expect(project.time_entries.first.redmine_project_id).to be(1)
    expect(project.time_entries.first.redmine_master_id).to be(1)

  end

end