module Manager
  class ProjectLibrary
    def to_csv(projects)
      column_labels = %w(Project  From To Status Masters)
      CSV.generate(headers: true) do |csv|
        csv << column_labels
        projects.each do |project|
          csv << [project.name, project.from, project.to, project.status] if project.actual_employee_names.blank?
          project.actual_employee_names.uniq.each do |master|
            csv << [project.name, project.from, project.to, project.status, master]
          end
        end
      end
    end
  end
end
