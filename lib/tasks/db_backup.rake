task :db_backup => :environment do
  # last_backup_name = `ls -Art ~/module_db_backup/ | tail -n 1 | head -n 1`
  # backup_name = last_backup_name.to_i + 1
  # puts <<-eos
  #   Backup Mongo databases to ~/module_db_backup/#{last_backup_name} folder
  # eos

  # today_date = Date.today
  # backup_folder_name = "#{today_date.strftime('%d.%m.%Y')}_backup"
  #
  # puts "mongodump --host 10.135.6.37:27017 -o /home/app/webapp/module_db_backup/#{backup_folder_name}/mongo"
  # `mongodump --host 10.135.6.37:27017 -o /home/app/webapp/module_db_backup/#{backup_folder_name}/mongo`
  #
  # puts "PGPASSWORD=#{ENV["POSTGRES_PASSWORD"]} pg_dump --host 10.135.6.37 -p 5432 -d #{ENV["POSTGRES_DB"]} -U #{ENV["POSTGRES_USER"]} -f /home/app/webapp/module_db_backup/#{backup_folder_name}/pg.sql"
  # `PGPASSWORD=#{ENV["POSTGRES_PASSWORD"]} pg_dump --host 10.135.6.37 -p 5432 -d #{ENV["POSTGRES_DB"]} -U #{ENV["POSTGRES_USER"]} -f "/home/app/webapp/module_db_backup/#{backup_folder_name}/pg.sql"`
  #
  # `tar -zcvpf /home/app/webapp/module_db_backup/#{backup_folder_name}.tar.gz /home/app/webapp/module_db_backup/#{backup_folder_name}`

  # file_path  = "/home/app/webapp/module_db_backup/#{backup_folder_name}.tar.gz"
  dirname = "/module_db_backup"

  Dir.glob("log/*hr_module*") do |filename|
    file_path = "#{Dir.pwd}/#{filename}"
    Utils::GdriveWrapper.upload_file file_path: file_path, dirname: dirname
    File.delete(file_path)
  end
end
