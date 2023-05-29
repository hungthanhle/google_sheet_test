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
  end

  def insert
    spreadsheet_id = ENV['SPREADSHEETS_ID'] #not worksheet S
    spreadsheet = @service.get_spreadsheet(spreadsheet_id)

    # HÀNH ĐỘNG 1: NEW SHEET => FROM TEMPLATE SHEET: copy data, format ?
    template_sheet_id = ENV['TEMPLATE_SHEET_ID']
    # spreadsheet_properties = spreadsheet.sheets.find { |sheet| sheet.properties.sheet_id == template_sheet_id.to_i }.properties

    new_sheet_name = Time.now.strftime('%d/%m/%Y %H:%M')
    requests = [
      {
        duplicate_sheet: {
          source_sheet_id: template_sheet_id,
          new_sheet_name: new_sheet_name,
          insert_sheet_index: spreadsheet.sheets.count + 1
        }
      }
    ]
    @service.batch_update_spreadsheet(spreadsheet_id, Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(requests: requests))

    # debugger
    # HÀNH ĐỘNG 2: SOME ACTION BY SHEET ID
    spreadsheet = @service.get_spreadsheet(spreadsheet_id)
    new_sheet_id = nil

    # let's find new_sheet.id
    spreadsheet.sheets.each do |sheet|
      if sheet.properties.title == new_sheet_name
        new_sheet_id = sheet.properties.sheet_id
        break
      end
    end
    return if new_sheet_id.blank?

    requests = [
      {
        copy_paste: {
          source: {
            sheet_id: template_sheet_id,
          },
          destination: {
            sheet_id: new_sheet_id
          },
          paste_type: "PASTE_NORMAL",
          paste_orientation: "NORMAL"
        }
      }
    ]
    @service.batch_update_spreadsheet(spreadsheet_id, Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(requests: requests))

    # debugger
    # HÀNH ĐỘNG 3: XÓA DỮ LIỆU TRONG KHOẢNG A1:L1000 <- ONLY BY SHEET NAME
    spreadsheet = @service.get_spreadsheet(spreadsheet_id)
    clear_request_body = Google::Apis::SheetsV4::ClearValuesRequest.new
    @service.clear_values(spreadsheet_id, "#{new_sheet_name}!A1:L1000", clear_request_body)

  end
end
