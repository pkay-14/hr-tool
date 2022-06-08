class Role
  include Mongoid::Document

  has_and_belongs_to_many :users
  belongs_to :resource, :polymorphic => true

  field :name, :type => String

  index({
    :name => 1,
    :resource_type => 1,
    :resource_id => 1
  },
  { :unique => true})

  scopify

  after_save do
    users.each(&:touch)
  end

  def self.remove_user_from_role(role,user)
    Role.find_by(name: role.to_s).users.delete(user)
  end
end
