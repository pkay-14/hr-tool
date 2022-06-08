class Employee::Vacations::VacationDetails::Main
  include Interactor
  include Interactor::Contracts

  expects do
    required(:master).filled
    required(:params).schema do
      required(:date).filled
    end
  end

  on_breach do |breaches|
    failed(breaches.map(&:messages).flatten)
  end

  def call
    vacation_days_left
  end

  private

  def vacation_days_left
    date = context.params[:date].to_date
    context.response = { days_available: context.master.earned_vacation_days(date),
                         entitlement_per_year: context.master.vacation_days_for_year(date.year)
    }
  end

  def failed(error)
    context.fail!(error: error)
  end
end
