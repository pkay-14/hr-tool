require "rails_helper"


RSpec.describe Acc::GeneralReportRow do

  before :all do
    Fabrication.manager.load_definitions
  end

  it "should represent one report row correctly with all main operations" do
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
      Acc::Constants::CHARGE_CONFERENCE_COMPENSATION => 10,
      Acc::Constants::CHARGE_SPORT_COMPENSATION => 10,
      Acc::Constants::CHARGE_GADGETS_COMPENSATION => 10,
      Acc::Constants::CHARGE_SOFTWARE_COMPENSATION => 10,
      Acc::Constants::CHARGE_OTHER => 5,
      Acc::Constants::CHARGE_TAX_COMPENSATION => 0,
      Acc::Constants::CHARGE_LAWYER_COMPENSATION => 0,
      Acc::Constants::CHARGE_ACCOUNTANT_COMPENSATION => 0,
      Acc::Constants::CHARGE_RENT_COMPENSATION => 0,
      Acc::Constants::CHARGE_BANK_COMPENSATION => 10,
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

    [Acc::AccountingService::CHARGE_WORK, Acc::AccountingService::CHARGE_OVERTIME, Acc::AccountingService::CHARGE_BONUS, Acc::AccountingService::CHARGE_TAX_COMPENSATION,
     Acc::AccountingService::CHARGE_ACCOUNTANT_COMPENSATION, Acc::AccountingService::CHARGE_RENT_COMPENSATION, Acc::AccountingService::CHARGE_OTHER,
     Acc::AccountingService::CHARGE_CONFERENCE_COMPENSATION, Acc::AccountingService::CHARGE_SPORT_COMPENSATION, Acc::AccountingService::CHARGE_BANK_COMPENSATION,
     Acc::AccountingService::CHARGE_GADGETS_COMPENSATION, Acc::AccountingService::CHARGE_SOFTWARE_COMPENSATION].each do |action|
      internal_operation = Acc::InternalOperation.new(action, Date.today, charges[action], master)
      operations = service.perform_action(internal_operation)
      operations.each do |operation|
        service.make_operation(operation)
      end
    end

    [Acc::Constants::DEDUCT_FOOD, Acc::Constants::DEDUCT_IMPRESTS, Acc::Constants::DEDUCT_GADGETS, Acc::Constants::DEDUCT_OTHERS].each do |action|
      internal_operation = Acc::InternalOperation.new(action, Date.today, deductions[action], master)
      operations = service.perform_action(internal_operation)
      operations.each do |operation|
        service.make_operation(operation)
      end
    end

    row = Acc::GeneralReportRow.new(owner, master, Date.today.month, Date.today.year)
    row.build_auto
    report_row = row.build_row

    report = report_row["report"]
	puts "!!!report #{report.values.inspect}"
    report.values.each {|val| puts "#{val['sub_type']}   #{val['balance']}"}

    charges = report.values[0..7].sum { |item| Monetize.parse(item["balance"]) }
    deductions = report.values[8..12].sum { |item| Monetize.parse(item["balance"]) }
    compensations = report.values[14..17].sum { |item| Monetize.parse(item["balance"]) }

    puts "charges:#{charges}"
    puts "deductions:#{deductions}"
    puts "compensations:#{compensations}"

	puts "MV: #{Monetize.parse(report[Acc::Constants::MASTERS_WORK]["balance"])/1.0527}"

    expect((charges-deductions+compensations)*1.0527).to eq(Monetize.parse(report[Acc::Constants::MASTERS_WORK]["balance"]))

  end

end

