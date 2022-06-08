namespace :encrypted_fields do

  task :add_unencrypted_fields => :environment do
    initial(PassportInfo, HardwareInfo)

    @users.each do |user|
      user.bank_accounts.each do |bank_account|
        add_unencrypted_data(bank_account, @bank_account_fields)
      end
      add_unencrypted_data(user.passport_info, @passport_info_fields) if user.passport_info
      add_unencrypted_data(user.hardware_info, @hardware_info_fields) if user.hardware_info
    end
  end

  task :verify => :environment do
    initial(PassportInfo, HardwareInfo)
    @masters = []
    errors = []
    @users.each do |user|
      user.bank_accounts.each do |bank_account|
        verify_data(bank_account, @bank_account_fields, errors)
      end
      verify_data(user.passport_info, @passport_info_fields, errors) if user.passport_info
      verify_data(user.hardware_info, @hardware_info_fields, errors) if user.hardware_info
    end
    p @masters.uniq.size
    p "=============================================================================="
    if errors.length > 0
      p "The following masters produced errors while migrating, please verify manually"
      p errors
    else
      p 'no errors!'
    end
  end

  task :encrypt => :environment do
    initial(PassportInfo, HardwareInfo)

    @users.each do |user|
      user.bank_accounts.each do |bank_account|
        encrypt_data(bank_account, @bank_account_fields)
      end
      encrypt_data(user.passport_info, @passport_info_fields) if user.passport_info
      encrypt_data(user.hardware_info, @hardware_info_fields) if user.hardware_info
    end
  end

  task :remove_unencrypted_fields => :environment do
    initial(PassportInfo, HardwareInfo)

    @users.each do |user|
      user.bank_accounts.each do |bank_account|
        remove_unencrypted_data(bank_account, @bank_account_fields)
      end
      remove_unencrypted_data(user.passport_info, @passport_info_fields) if user.passport_info
      remove_unencrypted_data(user.hardware_info, @hardware_info_fields) if user.hardware_info
    end
  end

  private

  def initial(passport_info, hardware_info)
    @bank_account_fields = %w(mfo current_account beneficiary_bank_acc beneficiary_IBAN_acc)
    @passport_info_fields = passport_info.fields.keys.map(&:to_sym) - [:_id, :accounting_agreement_date, :equipment_rent_agreement_date, :first_rent_agreement_date, :second_rent_agreement_date, :user_id]
    @hardware_info_fields = hardware_info.fields.keys.map(&:to_sym) - [:_id, :user_id]

    @users = User.all
  end

  def add_unencrypted_data(entity, fields)
    p "adding the fields for #{entity.user&.full_name} #{entity.class.to_s}"
    fields.each do |field|
      if !entity["unencrypted_#{field}".to_sym]
        entity["unencrypted_#{field}".to_sym] = entity.send(field.to_sym).to_s
      else
        p "unencrypted_#{field} found already. skipping"
      end
    end
    entity.save!
  end

  def verify_data(entity, fields, errors)
    @masters << entity.user&.full_name
    p "verifying data for #{entity.user&.full_name} #{entity.class.to_s}"
    fields.each do |field|
      unless entity.send(field.to_sym)&.force_encoding("utf-8").to_s == entity["unencrypted_#{field}".to_sym]
        errors.push "#{entity.user&.full_name} #{entity.class} #{field}"
      end
    end
  end

  def encrypt_data(entity, fields)
    p "encrypting the data for #{entity.user&.full_name} #{entity.class.to_s}"
    fields.each do |field|
      if entity["unencrypted_#{field}".to_sym]
        entity[field.to_sym] = entity["unencrypted_#{field}".to_sym]
      else
        p "unencrypted_#{field} not found. Skipping"
      end
    end
    entity.save!
  end

  def remove_unencrypted_data(entity, fields)
    p "removing the temp fields for #{entity.user&.full_name} #{entity.class.to_s}"
    fields.each do |field|
      if entity["unencrypted_#{field}".to_sym]   #make sure that a unencrypted_private_data exists.
        entity.unset("unencrypted_#{field}".to_sym)
      else
        p "unencrypted_#{field} not found. Skipping"
      end
    end
    entity.save!
  end

end
