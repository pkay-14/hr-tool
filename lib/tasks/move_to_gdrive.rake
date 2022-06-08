task :move_to_gdrive => :environment do
    users = User.where(:resume_url.ne => nil)
    resume_url3 = users.map {|u| [u.id.to_s, u.resume_url]}
    resume_url3 = resume_url3.to_h
    ocean = users.select {|u| u.resume_url.include?('ocean')}
    ocean.each do |user|
     resume_url = "#{user.resume_url.gsub('ocean.comfortsteel.com','seafile.mocintra.com').gsub(/https?/,'https')}?dl=1"
     puts resume_url
     file = Tempfile.new
     file.binmode
     begin
       open(resume_url) { |data| file.write data.read }
       file.close
       file_url = Utils::GdriveWrapper.upload_file file_path: file.path, dirname: user.remote_dirname, type: :resume
       file.unlink
       user.update_attribute :resume_url, file_url
     rescue
      puts user.id
     end
    end

    seafile = users.select {|u| u.resume_url.include?('seafile')}
    seafile.each do |user|
     resume_url = "#{user.resume_url.gsub('ocean.comfortsteel.com','seafile.mocintra.com').gsub(/https?/,'https')}?dl=1"
     #tmp_export_file = Tempfile.new(SecureRandom.uuid)
     file = Tempfile.new
     file.binmode
     begin
       open(resume_url) { |data| file.write data.read }
       puts resume_url
       file.close
       file_url = Utils::GdriveWrapper.upload_file file_path: file.path, dirname: user.remote_dirname, type: :resume
       file.unlink
       user.update_attribute :resume_url, file_url
     rescue
      puts user.id
     end
    end
end
