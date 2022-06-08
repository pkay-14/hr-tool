password = Rails.env.eql?('production') ? Rails.application.secrets.mongoid_encrypt_password : '3BiSWB1tSoZxTYc9Vhn0'
Mongoid::EncryptedFields.cipher = Gibberish::AES::CBC.new(password)
