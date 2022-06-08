module Manager
  class VacationLibrary
    def filter_vacation_date(vacations, from, to)
      return vacations unless from || to
      date_from = from.empty? ? nil : from.to_date
      date_to = to.empty? ? nil : to.to_date
      if date_from && date_to
        filtered = vacations.any_of({from: date_from.to_date..date_to.to_date}, {to: date_from.to_date..date_to.to_date})
      elsif date_from || date_to
        if date_from.present?
          filtered = vacations.any_of({:from.gte => date_from}, {:to.gte => date_from})
        else
          filtered = vacations.where({:from.lte => date_to})
        end
      else
        filtered = vacations
      end
      filtered
    end

    def export_to_csv(vacations)
      column_labels = %w[Master Type From To Half-day? Status]
      CSV.generate(headers: true) do |csv|
        csv << column_labels
        vacations.each do |vacation|
          status = vacation.status&.capitalize || 'Pending'
          if vacation.employee.present?
            if vacation.category.try(:capitalize) == 'Days-off' && vacation.from.year > Date.today.year
              vacation_type = 'Vacation'
            else
              vacation_type = vacation.category.try(:capitalize) == 'Days-off' ? 'Unpaid leave' : vacation.category.try(:capitalize)
            end
            csv << [vacation.employee.full_name, vacation_type, vacation.from, vacation.to, vacation.half_day? ? 'Yes' : 'No', status]
          end
        end
      end
    end
  end
end
