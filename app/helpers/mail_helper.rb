module MailHelper
  def masters_url_host
    case Rails.env
    when 'development', 'test'
      'masters.mocintra.local:8080'
    when 'staging'
      'masters.mocstage.com'
    when 'pre_production'
      'ppmm.mocstage.com'
    when 'production'
      'masters.mocintra.com'
    end
  end
end
