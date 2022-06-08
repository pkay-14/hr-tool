module Admin::EmployeesHelper

  def divisions
    User.get_divisions.sort_by(&:downcase)
  end

  def communities
    User.get_communities.sort_by(&:downcase)
  end

  def positions
    User.get_positions.sort_by(&:downcase)
  end

end
