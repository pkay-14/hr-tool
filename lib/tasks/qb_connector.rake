namespace :qb do
  task :test => :environment do

    access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, QB_ACCESS_TOKEN, QB_ACCESS_TOKEN_SECRET)
    service = Quickbooks::Service::AccessToken.new
    service.access_token = access_token
    service.company_id = QB_REALM_ID

    result = service.renew
    puts result.inspect

    unless result.error_code=0
      access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, result.token, result.secret)
    end

    service = Quickbooks::Service::Customer.new
    service.company_id = QB_REALM_ID
    service.access_token = access_token
    result = service.query()

    puts result.inspect

  end

  task :import_invoices => :environment do

    require "csv"

    file_name = "#{Rails.root}/tmp/import_invoices.csv"


    if File.exists?(file_name)
      puts "Importing ....."

      invoices = []
      File.open(file_name, "r").each do |line|
        invoices << line.split(",") unless line.include?("Client's fax #")
      end


      access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, QB_ACCESS_TOKEN, QB_ACCESS_TOKEN_SECRET)
      service = Quickbooks::Service::AccessToken.new
      service.access_token = access_token
      service.company_id = QB_REALM_ID

      result = service.renew
      puts result.inspect

      unless result.error_code=0
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, result.token, result.secret)
      end

      service = Quickbooks::Service::Customer.new
      service.company_id = QB_REALM_ID
      service.access_token = access_token

      invoices.each do |invoice_line|

        puts invoice_line[0]
        result = service.query("select * from Customer where DisplayName LIKE '%#{invoice_line[0]}%'")

        puts result.first.inspect

        unless result.first.nil?

          serviceItem = Quickbooks::Service::Item.new
          serviceItem.company_id = QB_REALM_ID
          serviceItem.access_token = access_token

          item = serviceItem.query("Select * from Item where sku='500'").first
          puts item.inspect

          puts "Importing invoice for #{result.first.fax_phone.inspect}"

          invoice = Quickbooks::Model::Invoice.new

          custRef = Quickbooks::Model::BaseReference.new
          custRef.name= "Customer"
          custRef.value= result.first.id.to_s

          invoice.customer_ref = custRef
          invoice.txn_date = invoice_line
          invoice.doc_number = "#{Date.today.strftime('%Y%m%d')}-#{Time.now.to_i}" # my custom Invoice # - can leave blank to have Intuit auto-generate it

          line_item = Quickbooks::Model::InvoiceLineItem.new
          line_item.amount = invoice_line[12]

          line_item.description = invoice_line[9]

          itemRef = Quickbooks::Model::BaseReference.new
          itemRef.name= "Service"
          itemRef.value= item.id.to_s

          line_item.sales_item! do |detail|
            detail.item_ref = itemRef # Item ID here
            detail.qantity = 1
            detail.unit_price=invoice_line[12]
          end

          invoice.line_items << line_item

          serviceInv = Quickbooks::Service::Invoice.new
          serviceInv.company_id = QB_REALM_ID
          serviceInv.access_token = access_token
          created_invoice = serviceInv.create(invoice)

          puts created_invoice.inspect

          sleep(2)
        end

      end


    else
      puts "No file found!!!!"
    end


  end


end
