module Manager
  class OvertimeLibrary
    def filter_overtime_date(overtimes, from, to)
      return overtimes unless from || to
      date_from = from.blank? ? nil : from.to_date
      date_to = to.blank? ? nil : to.to_date
      if date_from && date_to
        filtered = overtimes.where({:date.gte => date_from.to_date, :date.lte => date_to.to_date.end_of_day})
      elsif date_from || date_to
        filtered = date_from ? overtimes.where({:date.gte => date_from}) : overtimes.where({:date.lte => date_to.end_of_day})
      else
        filtered = overtimes
      end
      filtered
    end

    def filter_overtimes_for_export(overtimes, from, to, status)
      date_from = from.blank? ? nil : from.to_date
      date_to = to.blank? ? nil : to.to_date

      today = Date.today
      default_from = (today - 61).beginning_of_month
      default_to = today.end_of_month
      case status
      when 'confirmed'
        if date_from.present? && date_to.present?
          return overtimes.confirmed.where({:approved_on_date.gte => date_from.to_date, :approved_on_date.lte => date_to.to_date.end_of_day})
        elsif date_from.present? || date_to.present?
          return date_from ? overtimes.confirmed.where({:approved_on_date.gte => date_from}) : overtimes.where({:approved_on_date.lte => date_to.end_of_day})
        else
          return overtimes.confirmed.where({:approved_on_date.gte => default_from, :approved_on_date.lte => default_to.end_of_day})
        end
      when 'dismissed', 'pending'
        if date_from.present? && date_to.present?
          return overtimes.where({:date.gte => date_from.to_date, :date.lte => date_to.to_date.end_of_day})
        elsif date_from.present? || date_to.present?
          return date_from ? overtimes.where({:date.gte => date_from}) : overtimes.where({:date.lte => date_to.end_of_day})
        else
          return overtimes.where({:date.gte => default_from.beginning_of_day, :date.lte => default_from.end_of_day})
        end
      when '', nil
        if date_from.present? && date_to.present?
          return overtimes.dismissed.where({:date.gte => date_from.to_date, :date.lte => date_to.to_date.end_of_day}) |
            overtimes.confirmed.where({:approved_on_date.gte => date_from.to_date, :approved_on_date.lte => date_to.to_date.end_of_day}) |
            overtimes.where({status: nil, :date.gte => date_from.to_date, :date.lte => date_to.to_date.end_of_day})
        elsif date_from.present? || date_to.present?
          return date_from ? overtimes.where({status: nil, :date.gte => date_from}) | overtimes.confirmed.where({:approved_on_date.gte => date_from}) | overtimes.dismissed.where({:date.gte => date_from}) :
                   overtimes.where({status:nil, :date.lte => date_to.end_of_day}) |  overtimes.where({:approved_on_date.lte => date_to.end_of_day}) | overtimes.dismissed.where({:date.lte => date_to.end_of_day})

        else
          return (overtimes.dismissed.where({:date.gte => default_from.beginning_of_day, :date.lte => default_to.end_of_day}) |
            overtimes.confirmed.where({:approved_on_date.gte => default_from, :approved_on_date.lte => default_to.end_of_day}) |
            overtimes.dismissed.where({status: nil, :date.gte => default_from.beginning_of_day, :date.lte => default_to.end_of_day}))
        end
      else
        return (overtimes.dismissed.where({:date.gte => default_from.beginning_of_day, :date.lte => default_to.end_of_day}) |
          overtimes.confirmed.where({:approved_on_date.gte => default_from, :approved_on_date.lte => default_to.end_of_day}) |
          overtimes.where({status: nil, :date.gte => default_from.beginning_of_day, :date.lte => default_to.end_of_day}))
      end
    end

    def filter_overtime_approves_date(overtime_approves, from, to)
      return overtime_approves unless from || to
      date_from = from.empty? ? nil : from.to_date
      date_to = to.empty? ? nil : to.to_date
      if date_from && date_to
        filtered = overtime_approves.select{|approve| approve.overtime.date >= date_from.to_date && approve.overtime.date <= date_to.to_date}
      elsif date_from || date_to
        if date_from
          filtered =  overtime_approves.select{|approve| approve.overtime.date >= date_from}
        else
          filtered =  overtime_approves.select{|approve| approve.overtime.date.<= date_to}
        end
      else
        filtered = overtime_approves
      end
      filtered
    end

    def set_threshold_for_overtimes(overtimes, threshold)
      overtimes.where(:hours.gte => threshold)
    end

    def set_threshold_for_overtime_approves(overtime_approves, threshold)
      overtime_approves.select{|approve| approve.overtime.hours >= threshold}
    end

    def to_csv
      overtimer_ids = Overtime.distinct(:employee)
      masters = User.where({ _id: { :$in => overtimer_ids}})

      column_labels = %w(Date Hours Status)
        CSV.generate(headers: true) do |csv|
            masters.each do |master|
              csv << [master.full_name, master.moc_email, master.position]
              csv << column_labels
              master.overtimes.each do |overtime|
              csv << [overtime.date, overtime.hours.round(2), (overtime.status.nil? ? "Pending" : overtime.status.capitalize)]
              end
              csv << []
            end
        end
    end
  end
end
