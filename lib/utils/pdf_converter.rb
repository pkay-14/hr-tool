module Utils::PDFConverter

  def self.convert_to_pdf(file_path, username)
    filename = File.basename(file_path, ".*")
    dirname = File.dirname(file_path)

    unless is_pdf?(file_path)
      `lowriter --headless --convert-to pdf --outdir #{dirname} #{file_path}`
      File.delete(file_path)
    end

    converted_file_path = File.join(dirname, "#{filename}.pdf")
    renamed_file_path = "#{dirname}/#{username.gsub(' ','_')}.pdf"
    File.rename(converted_file_path, renamed_file_path)
    renamed_file_path
  end

  def self.is_pdf?(file_path)
    File.extname(file_path) == ".pdf"
  end

end
