class ExportController < ApplicationController
  # def files
  #   # render json: {a:1}
  #   Axlsx::Package.new do |p|
  #     p.workbook.add_worksheet(:name => "Pie Chart") do |sheet|
  #       # Add row
  #       sheet.add_row ["Simple Pie Chart"]
  #       %w(first second third).each { |label| sheet.add_row [label, rand(24)+1] }
  #       # Add Chart
  #       sheet.add_chart(Axlsx::Pie3DChart, :start_at => [0,5], :end_at => [10, 20], :title => "example 3: Pie Chart") do |chart|
  #         chart.add_series :data => sheet["B2:B4"], :labels => sheet["A2:A4"],  :colors => ['FF0000', '00FF00', '0000FF']
  #       end
  #     end
  #     p.serialize('simple.xlsx')
  #   end
  # end

  def files
    # render json: {a:1}
    set_up = "test_file"
    p = Axlsx::Package.new
    p.workbook.add_worksheet(:name => "Basic Worksheet") do |sheet|
      # sheet.add_row ["First Column", "Second", "Third"]
      # sheet.add_row [1, 2, 3]
      sheet.add_row ["Simple TABLE"]
      %w(hàng_1 hàng_2 hàng_3).each { |label| sheet.add_row [label, rand(24)+1] }
    end
    p.use_shared_strings = true
    # p.serialize('simple1.xlsx')
    send_data p.to_stream.read, type: "application/xlsx", filename: "simple2.xlsx"
  end
end
