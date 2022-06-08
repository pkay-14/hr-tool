require "rails_helper"


RSpec.describe Contractor do

  before :all do
    Fabrication.manager.load_definitions
  end

  it "calculates payment proportion properly" do

    master = Contractor.new(TEST_MASTER)
    owner = Contractor.new(TEST_OWNER)
    import_link = Fabricate(:test_link)

    service = Acc::AccountingService.new(owner)
    service.ensure_accounts_plan
    service.ensure_master_accounts(master)

    operation = Acc::InternalOperation.new(Acc::Constants::SET_MASTER_RATE, Date.today, 5, master)
    entry = service.perform_action(operation)

    expect(service.make_entry(entry.first)).to be(true)
    expect(service.make_entry(entry.last)).to be(true)
    expect(master.hourly_rate).to eq(Money.new(500))

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

    result = master.monthly_invoices_total(Date.today.month, Date.today.year, Money.new(80000))
    expect(result[0][:total_hours]).to eq(25)
    expect(result[0][:share]).to eq(Money.new(36364))
    expect(result[1][:total_hours]).to eq(30)
    expect(result[1][:share]).to eq(Money.new(43636))
    expect(result[0][:project_id]).to eq(1)
    expect(result[1][:project_id]).to eq(2)

  end


  it "retrieves correctly all charges for a specific month" do

    master = Contractor.new(TEST_MASTER)
    owner = Contractor.new(TEST_OWNER)
    import_link = Fabricate(:test_link)

    service = Acc::AccountingService.new(owner)
    service.ensure_accounts_plan
    service.ensure_master_accounts(master)

    operation = Acc::InternalOperation.new(Acc::Constants::SET_MASTER_RATE, Date.today, 5, master)
    entry = service.perform_action(operation)
    service.make_entry(entry.first)
    operation.transaction_type_id = Acc::Constants::SET_ACCOUNTANT_RATE
    entry = service.perform_action(operation)
    service.make_entry(entry.first)
    operation.transaction_type_id = Acc::Constants::SET_LAWYER_RATE
    entry = service.perform_action(operation)
    service.make_entry(entry.first)
    operation.transaction_type_id =Acc::Constants::SET_RENT_RATE
    entry = service.perform_action(operation)
    service.make_entry(entry.first)
    operation.transaction_type_id =Acc::Constants::SET_TAXES_RATE
    entry = service.perform_action(operation)
    service.make_entry(entry.first)


  end

end