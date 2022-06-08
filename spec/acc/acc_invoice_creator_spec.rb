require "rails_helper"


RSpec.describe Acc::InvoiceManager do

  before :all do
    Fabrication.manager.load_definitions
  end

  it "creates inner and outer invoices for e specific master and specific period" do

    master = Contractor.new(TEST_MASTER)
    owner = Contractor.new(TEST_OWNER)
    import_link = Fabricate(:test_link)

    service = Acc::AccountingService.new(owner)
    service.ensure_accounts_plan
    service.ensure_master_accounts(master)
    operation = Acc::InternalOperation.new(Acc::Constants::SET_MASTER_RATE, Date.today, 5, master)
    entries = service.perform_action(operation)

    expect(service.make_entry(entries.first)).to be(true)
    expect(service.make_entry(entries.last)).to be(true)
    expect(master.hourly_rate).to eq(Money.new(500))
    operation = Acc::InternalOperation.new(Acc::Constants::CHARGE_WORK, Date.today, 0, master)
    entries = service.perform_action(operation)
    entries.each do |entry|
      service.make_entry(entry)
    end

    operation = Acc::InternalOperation.new(Acc::Constants::CALCULATE_INVOICE, Date.today, 0, master)
    entries = service.perform_action(operation)
    entries.each do |entry|
      service.make_entry(entry)
    end

    expect(master.personal_balance(Acc::Constants::INVOICES_CALCULATED)).to eq(Money.new(80000))

    uat = Contractor.new(TEST_UAT)
    link = Fabricate(:test_uat)
    project1= Fabricate(:test_project) do
      uat_acceptor link
    end
    project2= Fabricate(:test_project)do
      uat_acceptor link
    end


    5.times do
      Fabricate(:time_entry) do
        project_id project1.id
        time 5
        master_id import_link.id
      end
    end

    15.times do
      Fabricate(:time_entry) do
        project_id project2.id
        time 2
        master_id import_link.id
      end
    end

    creator = Acc::InvoiceManager.new(Date.today.month, Date.today.year)
    creator.create_invoices(master)

    expect(Acc::OuterInvoice.count).to eq(1)
    expect(Acc::Invoice.count).to eq(2)
    expect(Acc::OuterInvoice.first.invoices.count).to eq(2)
    expect(Acc::Invoice.first.sum).to eq(Money.new(36364))
    expect(Acc::Invoice.last.sum).to eq(Money.new(43636))

  end

end