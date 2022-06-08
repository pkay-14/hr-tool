require 'rubygems'

class Calendar
  def self.working_day?(date, country = nil)
    country ||= Country.find_by(name: 'Ukraine')
    date = date.to_date
    !date.saturday? && !date.sunday? && Holiday.where(date: date, country: country).none?
  end
end
