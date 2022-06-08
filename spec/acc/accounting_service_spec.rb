require "rails_helper"


RSpec.describe Acc::AccountingService do

  before :all do
    Fabrication.manager.load_definitions
  end

  it "creates basic accounts correctly" do
    owner = Owner.new(TEST_OWNER)

    service = Acc::AccountingService.new(owner)
    service.ensure_accounts_plan

    accounts = Acc::Account.all
    expect(accounts.count).to eq(9)
  end


  it "creates masters accounts properly" do
    owner = Owner.new(TEST_OWNER)
    master = Contractor.new(TEST_MASTER)

    service = Acc::AccountingService.new(owner)
    service.ensure_master_accounts(master)

    masters_accounts = Acc::Account.all
    expect(masters_accounts.count).to eq(27)

  end


  it "creates operations and entries to set master related rates/ reverse entries properly" do

    owner = Owner.new(TEST_OWNER)
    master = Contractor.new(TEST_MASTER)

    service = Acc::AccountingService.new(owner)
    service.ensure_accounts_plan
    service.ensure_master_accounts(master)


    [Acc::Constants::SET_MASTER_RATE, Acc::Constants::SET_ACCOUNTANT_RATE, Acc::Constants::SET_LAWYER_RATE, Acc::Constants::SET_RENT_RATE, Acc::Constants::SET_TAXES_RATE].each do |action|
      internal_operation = Acc::InternalOperation.new(action, Date.today, 10, master)
      operations = service.perform_action(internal_operation)
      masters_account = Acc::Account.by_sub_type(Acc::AccountingService::TRANSACTIONS[action].first[:dt]).by_master_id(master.id).first

      operations.each do |operation|
        service.make_operation(operation)
      end


      expect(operations.last.entries.last).not_to eq(nil)
      expect(operations.last.entries.last.debit_account.id).to eq(masters_account.id)
      expect(operations.last.entries.last.sum).to eq(Money.new(1000))
      expect(operations.last.entries.last.made?).to be(true)

      masters_account.reload

      expect(masters_account.class).to be(Acc::Account)
      expect(masters_account.debit_balance).to eq(Money.new(1000))

    end
  end

  it "creates operations and entries to bill for monthly services delivered by master" do

    rates ={
        Acc::Constants::SET_MASTER_RATE => 5,
        Acc::Constants::SET_ACCOUNTANT_RATE => 10,
        Acc::Constants::SET_LAWYER_RATE => 10,
        Acc::Constants::SET_RENT_RATE => 10,
        Acc::Constants::SET_TAXES_RATE => 10
    }

    charges = {
        Acc::Constants::CHARGE_WORK => 0,
        Acc::Constants::CHARGE_OVERTIME => 10,
        Acc::Constants::CHARGE_BONUS => 10,
        Acc::Constants::CHARGE_ON_CALL_SHIFT=> 10,
        Acc::Constants::CHARGE_CONFERENCE_COMPENSATION => 10,
        Acc::Constants::CHARGE_SPORT_COMPENSATION => 10,
        Acc::Constants::CHARGE_BANK_COMPENSATION => 10,
        Acc::Constants::CHARGE_GADGETS_COMPENSATION => 10,
        Acc::Constants::CHARGE_SOFTWARE_COMPENSATION => 10,
        Acc::Constants::CHARGE_TAX_COMPENSATION => 0,
        Acc::Constants::CHARGE_LAWYER_COMPENSATION => 0,
        Acc::Constants::CHARGE_ACCOUNTANT_COMPENSATION => 0,
        Acc::Constants::CHARGE_RENT_COMPENSATION => 0,
        Acc::Constants::CHARGE_OTHER => 5
    }

    deductions ={
        Acc::Constants::DEDUCT_ADVANCE => 10,
        Acc::Constants::DEDUCT_FOOD => 10,
        Acc::Constants::DEDUCT_IMPRESTS => 10,
        Acc::Constants::DEDUCT_GADGETS => 10,
        Acc::Constants::DEDUCT_OTHERS => 10
    }

    owner = Owner.new(TEST_OWNER)
    master = Contractor.new(TEST_MASTER)

    service = Acc::AccountingService.new(owner)
    service.ensure_accounts_plan
    service.ensure_master_accounts(master)


    #Setup masters rates
    [Acc::AccountingService::SET_MASTER_RATE, Acc::AccountingService::SET_ACCOUNTANT_RATE, Acc::AccountingService::SET_LAWYER_RATE, Acc::AccountingService::SET_RENT_RATE, Acc::AccountingService::SET_TAXES_RATE].each do |action|
      internal_operation = Acc::InternalOperation.new(action, Date.today, rates[action], master)
      operations = service.perform_action(internal_operation)
      operations.each do |operation|
        service.make_operation(operation)
      end
    end

    master_account = Acc::Account.by_sub_type(Acc::AccountingService::MASTERS_WORK).by_master_id(master.id).first

    [Acc::AccountingService::CHARGE_WORK, Acc::AccountingService::CHARGE_OVERTIME, Acc::AccountingService::CHARGE_BONUS, Acc::AccountingService::CHARGE_ON_CALL_SHIFT, Acc::AccountingService::CHARGE_TAX_COMPENSATION, Acc::AccountingService::CHARGE_LAWYER_COMPENSATION,
     Acc::AccountingService::CHARGE_ACCOUNTANT_COMPENSATION, Acc::AccountingService::CHARGE_RENT_COMPENSATION, Acc::AccountingService::CHARGE_OTHER,
	 Acc::AccountingService::CHARGE_CONFERENCE_COMPENSATION, Acc::AccountingService::CHARGE_SPORT_COMPENSATION, Acc::AccountingService::CHARGE_BANK_COMPENSATION,
	 Acc::AccountingService::CHARGE_GADGETS_COMPENSATION, Acc::AccountingService::CHARGE_SOFTWARE_COMPENSATION].each do |action|
      internal_operation = Acc::InternalOperation.new(action, Date.today, charges[action], master)
      operations = service.perform_action(internal_operation)
      service.make_operation(operations.first)
      master_account.reload
    end

    [Acc::AccountingService::DEDUCT_ADVANCE, Acc::AccountingService::DEDUCT_FOOD, Acc::AccountingService::DEDUCT_IMPRESTS, Acc::AccountingService::DEDUCT_GADGETS,
     Acc::AccountingService::DEDUCT_OTHERS].each do |action|
      internal_operation = Acc::InternalOperation.new(action, Date.today, deductions[action], master)
      operations = service.perform_action(internal_operation)
      service.make_operation(operations.first)
    end

    master_account.reload

    expect(master_account.credit_balance).to eq(Money.new(90500))

    [Acc::AccountingService::CALCULATE_INVOICE, Acc::AccountingService::SEND_INVOICE, Acc::AccountingService::APPROVE_INVOICE_PAYED].each do |action|
      internal_operation = Acc::InternalOperation.new(action, Date.today, 0, master)
      operations = service.perform_action(internal_operation)
      service.make_operation(operations.first)
    end

    master_account.reload
    expect(master_account.credit_balance).to eq(Money.new(0))

    invoice_payed_account = Acc::Account.by_sub_type(Acc::AccountingService::INVOICES_PAYED).by_master_id(master.id).first
    expect(invoice_payed_account.credit_balance).to eq(Money.new(90500))


  end


end
