module Utils::GdriveWrapper
  def self.upload_file(options = {})
    file_path = options[:file_path]
    dirname = options[:dirname]
    file_name = options[:type] == :resume ? 'resume.pdf' : File.basename(file_path)
    put_and_get(file_path, file_name, dirname)
  end

  def self.put_and_get(file_path,new_name,dirname)
    file = put_file(file_path, new_name, dirname)
    share_file(file)
    file.human_url
  end

  def self.put_file(in_filename, out_filename, dirname)
    result = current.file_by_title("#{dirname}/#{out_filename}")
    if result
      p "update file"
      result.update_from_file(in_filename)
      result
    else
      p "file not found, upload file"
      current.upload_from_file(in_filename, "#{dirname}/#{out_filename}")
    end
  end

  def self.get_file(title)
    current.file_by_title(title)
  end

  def self.get_file_by_url(url)
    current.file_by_url(url)
  end

  def self.get_files
    current.files.each do |file|
      p "------------------- #{file.title}"
    end
  end

  def self.spreadsheet_by_title(title)
    current.spreadsheet_by_title(title)
  end

  def self.spreadsheets
    current.spreadsheets.each do |spreadsheet|
      p spreadsheet.title
    end
  end

  private
  def self.share_file(file)
    file.acl.push(type: 'domain', domain: 'masterofcode.com', role: 'reader') unless file.acl.to_enum.find {|d| d.role=="domain" && d.domain=="masterofcode.com"}
  end

  def self.get_file_share_link(title)
    file = current.file_by_title(title)
    file.human_url if file
  end

  def self.current
    @session ||= session
  end

  def self.session
    GoogleDrive::Session.from_service_account_key("config/external_services/google_service_account.json")
  end
end

