require "rails_helper"


RSpec.describe Acc::TimeEntry do

  before :all do
    Fabrication.manager.load_definitions
  end

  it "imports TimeEntries from Redmine correctly" do

    import_link = instance_double("Acc::ImportLink", id: 1)

    5.times do
      Fabricate(:time_entry) do
        project_id 1
        time 5
        master_id import_link.id
      end
    end

    15.times do
      Fabricate(:time_entry) do
        project_id 2
        time 2
        master_id import_link.id
      end
    end

    result = Acc::TimeEntry.monthly_by_master(Date.today.month,Date.today.year,import_link).entries

    expect(result.count).to be_equal(2)
    expect(result[0].project_id).to eq(1)
    expect(result[1].project_id).to eq(2)
    expect(result[0].total_hours).to eq(25)
    expect(result[1].total_hours).to eq(30)

  end

end