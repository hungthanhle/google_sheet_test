require 'google/apis/sheets_v4'
# https://www.rubydoc.info/gems/google-apis-sheets_v4/0.22.0

class GoogleSheetsService
  def initialize
    credentials = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open("config/rails-tutorail.json"),
      scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS
    )
    @service = Google::Apis::SheetsV4::SheetsService.new
    @service.authorization = credentials

    spreadsheet_id = ENV['SPREADSHEETS_ID'] #not worksheet S
    @spreadsheet = @service.get_spreadsheet(spreadsheet_id)
  end

  def insert
    template_sheet_id = ENV['TEMPLATE_SHEET_ID']
    new_sheet_name = new_sheet_with_template(template_sheet_id)
    # định TRUYỀN SPREADSHEET VÀO BA HÀM NÀY NHƯNG KHÔNG
    new_sheet_id = sheet_id_in_spreadsheet(new_sheet_name)
    # debugger
    copy_paste_action(template_sheet_id, new_sheet_id)
    # debugger
    truncate_value(new_sheet_name, "A1", "L1000")

    header = ["MSV", "Họ và tên", "Ngày sinh", "Khoa", "Lớp", "Chỉ số",	"Ghi chú"]
    values = [header]
    row_data = ["0", "Hùng", "99", "Điện", "Automation", "1000000", "Good"]
    values << row_data
    # draft input
    1.upto(17) do |n|
      row_data = [
        Array.new(3){[*"A".."Z",*"a".."z", *"0".."9"].sample}.join,
        Array.new(5){[*"A".."Z",*"a".."z", *"0".."9"].sample}.join,
        Array.new(4){[*"0".."9"].sample}.join,
        Array.new(20){[*"A".."Z",*"a".."z", *"0".."9"].sample}.join,
        Array.new(20){[*"A".."Z",*"a".."z", *"0".."9"].sample}.join,
        Array.new(7){[*"0".."9"].sample}.join,
        Array.new(20){[*"A".."Z",*"a".."z", *"0".."9"].sample}.join,
      ]
      values << row_data
    end 
    # debugger
    insert_values(new_sheet_name, values)
  end

  def new_sheet_with_template template_sheet_id
    # HÀNH ĐỘNG 1: NEW SHEET => FROM TEMPLATE SHEET: copy data, format
    # spreadsheet_properties = spreadsheet.sheets.find { |sheet| sheet.properties.sheet_id == template_sheet_id.to_i }.properties
    spreadsheet_id = @spreadsheet.spreadsheet_id
    new_sheet_name = Time.now.strftime('%d/%m/%Y %H:%M')
    requests = [
      {
        duplicate_sheet: {
          source_sheet_id: template_sheet_id,
          new_sheet_name: new_sheet_name,
          insert_sheet_index: @spreadsheet.sheets.count + 1
        }
      }
    ]
    @service.batch_update_spreadsheet(spreadsheet_id, Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(requests: requests))
    return new_sheet_name
  end

  def sheet_id_in_spreadsheet sheet_name
    new_sheet_id = nil
    # let's find new_sheet.id
    @spreadsheet.sheets.each do |sheet|
      if sheet.properties.title == sheet_name
        new_sheet_id = sheet.properties.sheet_id
        break
      end
    end
    return new_sheet_id
  end

  def copy_paste_action template_sheet_id, target_sheet_id
    # HÀNH ĐỘNG 2: SOME copy paste ? ACTION BY SHEET ID
    spreadsheet_id = @spreadsheet.spreadsheet_id
    requests = [
      {
        copy_paste: {
          source: {
            sheet_id: template_sheet_id,
          },
          destination: {
            sheet_id: target_sheet_id
          },
          paste_type: "PASTE_NORMAL",
          paste_orientation: "NORMAL"
        }
      }
    ]
    @service.batch_update_spreadsheet(spreadsheet_id, Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(requests: requests))
  end

  def truncate_value sheet_name, from, to #vd: A1, L1000
    # HÀNH ĐỘNG 3: XÓA DỮ LIỆU TRONG KHOẢNG A1:L1000 <- ONLY BY SHEET NAME
    spreadsheet_id = @spreadsheet.spreadsheet_id
    clear_request_body = Google::Apis::SheetsV4::ClearValuesRequest.new
    @service.clear_values(spreadsheet_id, "#{sheet_name}!#{from}:#{to}", clear_request_body)
  end

  def insert_values sheet_name, values
    value_range = Google::Apis::SheetsV4::ValueRange.new(values: values)
    range = "#{sheet_name}!A1:L#{values.count}"
    spreadsheet_id = @spreadsheet.spreadsheet_id
    response = @service.update_spreadsheet_value(
      spreadsheet_id,
      range,
      value_range,
      value_input_option: 'USER_ENTERED'
    )
  end
end
