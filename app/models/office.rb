class Office
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::History::Trackable
  include Mongoid::Paranoia

  field :name, type: String

  belongs_to :country
  has_many :users

  # track_history   on: [:all],       # track title and body fields only, default is :all
  #                 modifier_field: :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
  #                 modifier_field_inverse_of: :nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
  #                 version_field: :version,   # adds "field :version, :type => Integer" to track current version, default is :version
  #                 track_create: true,    # track document creation, default is false
  #                 track_update: true,     # track document updates, default is true
  #                 track_destroy: true     # track document destruction, default is false


end