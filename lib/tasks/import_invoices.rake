namespace :acc do
  desc 'Generate invoice files from XLSX statement file'
  task :import_invoice_statement => :environment do
    Rake.application.require "#{Rails.root}/lib/qbagent/statement_processor"

    import_path="#{Rails.root}/tmp/import/statements/sales/in"
    processor = StatementProcessor.new("#{Rails.root}/tmp/import/invoices/in")
    Dir.glob(import_path+"/*.xlsx") do |file|
      next if file == '.' or file == '..'
      puts file
      processor.process(file)
    end
  end


  desc 'Import invoices from tmp/invoices/in to connected QB company'
  task :qb_invoices_load => :environment do
    Rake.application.require "#{Rails.root}/lib/qbagent/invoice_processor"
    import_path="#{Rails.root}/tmp/import/invoices/in"
    processed_path="#{Rails.root}/tmp/import/invoices/processed"

    InvoiceProcessor.new(import_path, processed_path).manual_run


  end

end