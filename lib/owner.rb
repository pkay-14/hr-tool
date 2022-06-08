class Owner

  attr_accessor :hr_module_user
  attr_accessor :id


  def initialize(id)
    self.id=id
    self.hr_module_user = User.where(id: id).first
  end

end
