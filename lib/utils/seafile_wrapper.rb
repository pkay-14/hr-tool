# TODO: Need refactoring
# def perform(user_id)
#   user= User.find(user_id)
#   #dirname   =  user.remote_dirname ? user.remote_dirname : "/#{user.resume_file}"
#   user.create_sf_dir
#   #  user.update_attribute(:remote_dirname , dirname) if  $sf.download_dir(dirname).exclude?('/files/') && $sf.create_dir(dirname).include?('success')
#   file_path= user.resume.path
#   path = File.dirname(file_path)
#   user.remote_filename =  user.resume_file
#   new_name=""
#   user.test_task.skip_scm_url_validation = true if user.test_task
#   user.save
#   if Utils::UNCONVERTABLE_EXTENSION.include? File.extname(file_path)
#     new_name = "#{user.remote_filename}#{File.extname(file_path)}"
#     #user.resume_url = Utils::put_and_get(file_path,new_name,user.remote_dirname)
#   else
#     if Utils::convert(file_path,path)
#       File.delete(file_path)
#       basename = File.basename(file_path, '.*')
#       file_path = "#{path}/#{basename}.pdf"
#       new_name = "#{user.remote_filename}.pdf"
#     end
#   end
#   user.resume_url =  Utils::put_and_get(file_path,new_name,user.remote_dirname)
#   File.delete("#{path}/#{new_name}") if user.save
# end


module Utils::SeafileWrapper

  def self.upload_file(options = {})
    file_path = options[:file_path]
    dirname = options[:dirname]
    file_name = options[:type] == :resume ? 'resume.pdf' : File.basename(file_path)
    put_and_get(file_path, file_name, dirname)
  end

  def self.put_and_get(file_path, new_name, dirname)
    path = File.dirname(file_path)
    File.rename(file_path, "#{path}/#{new_name}")
    put_resume("#{path}/#{new_name}", "#{new_name}", dirname)
    p "after put resume"
    #resume_url = $sf.create_file_share_link("#{dirname}/#{new_name}")
    #until resume_url.include?('ocean')
    #  sleep(rand(7))
    #  resume_url = $sf.create_file_share_link("#{dirname}/#{new_name}")
    #end
    #   p (resume_url)
    #  resume_url
    p new_name
    p dirname
    self.get_file_share_link("#{dirname}/#{new_name}")
  end

  def self.get_file_share_link(remote_path)

    resume_url = $sf.create_file_share_link(remote_path)

    until resume_url.include?('seafile')
      sleep(rand(7))
      resume_url = $sf.create_file_share_link(remote_path)
    end
    resume_url
  end

  def self.put_resume(in_filename,out_filename,dirname)
    result = $sf.file_link("#{dirname}/#{out_filename}")
    if result == "File not found"
      p "file not found"
      $sf.upload_file(in_filename,dirname)
    elsif result ==  "{detail: You do not have permission to perform this action.}"
      sleep(3)
      self.put_resume(in_filename,out_filename,dirname)
    else
      p "update file"
      $sf.update_file(in_filename,"#{dirname}/#{out_filename}",$sf.repo )
    end
  end

  def self.put_test_file(in_filename,out_filename,dirname)
    result = $sf.file_link("#{dirname}/test_files/#{out_filename}")
    if result == "File not found"
      $sf.upload_file(in_filename,"#{dirname}/test_files")
    elsif result ==  "{detail: You do not have permission to perform this action.}"
      sleep(3)
      self.put_test_file(in_filename,out_filename,dirname)
    else
      $sf.update_file(in_filename,"#{dirname}/test_files/#{out_filename}",$sf.repo )
    end
  end

  def self.put_photo_file(in_filename,out_filename,dirname)
    result = $sf.file_link("#{dirname}/photo/#{out_filename}")
    if result == "File not found"
      $sf.upload_file(in_filename,"#{dirname}/photo")
    elsif result ==  "{detail: You do not have permission to perform this action.}"
      sleep(3)
      self.put_photo_file(in_filename,out_filename,dirname)
    else
      $sf.update_file(in_filename,"#{dirname}/photo/#{out_filename}",$sf.repo )
    end
  end
end
