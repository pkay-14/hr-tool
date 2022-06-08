module ApplicationConcern
  extend ActiveSupport::Concern

  included do
    helper_method :master_cabinet?
    helper_method :only_master_role?
    helper_method :to_boolean
  end

  def master_cabinet?
    params[:master] == 'true' || params.dig(:user, :master_cabinet) == 'true'
  end

  def only_master_role?
    params[:only_role] == 'true'
  end

  def to_boolean(str)
    str.in?(%w(true 1))
  end

end