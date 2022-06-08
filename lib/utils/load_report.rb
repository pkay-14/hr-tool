module Utils
  class LoadReport

    def initialize(options = {})
      @master = User.find(options[:master_id]) if options[:master_id]
      @name = options[:master_id] ? @master.full_name : "All masters"
      from_date = options[:from_date] || Date.today - 6.months
      to_date = options[:from_date] || Date.today
      @range = (from_date..to_date).select {|d| d.day == 1}
    end

    def generate
      chart_range = ChartRange.new(@range)
      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(:name => "#{@name} load stats") do |sheet|
          sheet.add_row ['Month', 'Load level']
          @range.each do |date|
            if @master
              sheet.add_row [ date.strftime("%m/%Y"), @master.month_load_level(date)]
            else
              sheet.add_row [ date.strftime("%m/%Y"), User.developers_month_load_level(date)]
            end
          end
          sheet.add_chart(Axlsx::LineChart, :title => "#{@name} load stats", :rotX => 30, :rotY => 20) do |chart|
            chart.start_at 4, 0
            chart.end_at 14, 20
            chart.add_series :data => sheet["A2:A#{chart_range.u_bound}"], :title => sheet["A1"], :color => "FF0000"
            chart.add_series :data => sheet["B2:B#{chart_range.u_bound}"], :title => sheet["B1"], :color => "00FF00"
            chart.catAxis.title = 'Month'
            chart.valAxis.title = 'Load level'
          end
        end
        p.serialize("tmp/reports/#{@name}.xlsx")
      end

    end

  end

  class ChartRange
    attr_accessor :l_bound, :u_bound

    def initialize(range)
      @l_bound = 2
      @u_bound = range.count + 1
    end
  end

end
