class Skill
  include Mongoid::Document

  validates_uniqueness_of :name

  field :name, type: String
  field :custom_name, type: String
  field :level, type: String

  embedded_in :user

  index :name => 1

  SKILLS = User::DEV_TECH.sort_by(&:downcase)
  LEVEL = %w( Junior Middle Senior )

end
