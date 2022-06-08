task :export_hardware => :environment do

  CSV.foreach(f) do |row|
      email = row[3]
      @master = User.where(moc_email: email).first
      if @master.present?
        dev_type = row[11]
        if !dev_type.present?
          puts "!!!!!! empty #{email}->>>> #{dev_type}"
        elsif dev_type.scan(/мон/i).present?
          mon(row)
        elsif dev_type.scan(/(порт.{1,}комп|ноут)/i).present?
          notebook(row)
        elsif dev_type.scan(/(омп|блок)/i).present?
          pc(row)
        else
          puts "!!!!!! else #{email}->>>> #{dev_type}"
        end
      else
        puts "@@@@@@@ #{email}"
      end
  end
end
def pc(row)
  pc = @master.pcs.create(uid: row[10].to_i)
  pc.hardwares.create(type: 'cpu', model: row[12], user_id: @master.id) if row[12].present?
  pc.hardwares.create(type: 'MotherBoard', model: row[13], user_id: @master.id) if row[13].present?
  if row[14].present?
    rams = row[14].split(/,|\+/).map do |el|
      els = el.split(/\*|x/)
      els = [els[1]] * els[0].to_i if els.count > 1
      els
    end
    rams.flatten.each{|ram| pc.hardwares.create(type: 'Ram', model: ram, user_id: @master.id) }
  end
  pc.hardwares.create(type: 'Hdd', model: row[15], user_id: @master.id) if row[15].present?
  pc.hardwares.create(type: 'Vga', model: row[16], user_id: @master.id) if row[16].present?
  @master.hardwares.create(type: 'display', model: row[18], uid:row[17].to_i, user_id: @master.id) if row[17].present? || row[18].present?
  @master.hardwares.create(type: 'display', model: row[20], uid:row[19].to_i, user_id: @master.id) if row[19].present? || row[20].present?
  @master.hardwares.create(type: 'ups', model: row[23], uid: row[21], serial: row[24], condition: row[25], user_id: @master.id) if row[23].present? || row[21].present? || row[24].present? || row[25].present?
end


def notebook(row)
  @master.hardwares.create(type: 'notebook', model: row[13]) if row[13].present?
  @master.hardwares.create(type: 'display', model: row[18], uid:row[17].to_i) if row[17].present? || row[18].present?
  @master.hardwares.create(type: 'display', model: row[20], uid:row[19].to_i) if row[19].present? || row[20].present?
  @master.hardwares.create(type: 'ups', model: row[23], uid: row[21].to_i, serial: row[24], condition: row[25]) if row[23].present? || row[21].present? || row[24].present? || row[25].present?

end

def mon(row)
  @master.hardwares.create(type: 'display', model: row[18], uid:row[17].to_i) if row[17].present? || row[18].present?
  @master.hardwares.create(type: 'display', model: row[20], uid:row[19].to_i) if row[19].present? || row[20].present?
  @master.hardwares.create(type: 'ups', model: row[23], uid: row[21], serial: row[24], condition: row[25]) if row[23].present? || row[21].present? || row[24].present? || row[25].present?
end



=begin
3 = email
10 = inv number
11 = dev type
12= cpu
13= MB
14= ram
15= HDD
16=VGA (not 'int')
17= inv mon1
18= mon model1
19= inv mon2
20= mon model2
21= ups inv num
23= ups model
24= ups serial
25= ups condition

1 pc
2 hardware

=end

