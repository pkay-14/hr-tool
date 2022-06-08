class Country
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::History::Trackable
  include Mongoid::Paranoia

  TIME_ZONES = [
    {country: 'Ukraine', time_zone: 'Kyiv'},
    {country: 'Canada', time_zone: 'Central Time (US & Canada)'},
    {country: 'USA', time_zone: 'Pacific Time (US & Canada)'},
  ]

  field :name, type: String
  field :vacation_days_per_year, type: Float, default: 0
  field :sick_days_per_year, type: Float, default: 0

  has_many :masters, class_name: "User", inverse_of: :country
  has_many :offices
  has_many :holidays

  accepts_nested_attributes_for :offices, :holidays, reject_if: :all_blank, allow_destroy: true

  # track_history   on: [:all],       # track title and body fields only, default is :all
  #                 modifier_field: :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
  #                 modifier_field_inverse_of: :nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
  #                 version_field: :version,   # adds "field :version, :type => Integer" to track current version, default is :version
  #                 track_create: true,    # track document creation, default is false
  #                 track_update: true,     # track document updates, default is true
  #                 track_destroy: true     # track document destruction, default is false
  #

  def time_zone
    TIME_ZONES.select {|el| el[:country] == self.name}.dig(0, :time_zone)
  end

end