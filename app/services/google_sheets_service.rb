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

    # HÀNH ĐỘNG 1: STILL INSERT NEW SHEET => NOT RENAME LAST SHEET
    rewrite_sheet = spreadsheet.sheets.last
    rewrite_sheet_id = rewrite_sheet.instance_variable_get('@properties').instance_variable_get('@sheet_id') #ENV['TEMPLATE_ID'] ?? original ??
    # spreadsheet_properties = spreadsheet.sheets.find { |sheet| sheet.properties.sheet_id == rewrite_sheet_id.to_i }.properties

    rewrite_sheet_name = Time.now.strftime('%d/%m/%Y %H:%M')
    requests = [
      {
        duplicate_sheet: {
          source_sheet_id: rewrite_sheet_id,
          new_sheet_name: rewrite_sheet_name
          # insert_sheet_index: spreadsheet.sheets.count + 1
        }
      }
    ]
    @service.batch_update_spreadsheet(spreadsheet_id, Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(requests: requests))

    debugger
    # HÀNH ĐỘNG 2
    spreadsheet = @service.get_spreadsheet(spreadsheet_id)
    new_sheet_id = nil
    spreadsheet.sheets.each do |sheet|
      if sheet.properties.title == rewrite_sheet_name
        new_sheet_id = sheet.properties.sheet_id
        break
      end
    end
    return if new_sheet_id.blank?
    requests = [
      {
        copy_paste: {
          source: {
            sheet_id: rewrite_sheet_id,
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

    debugger
    # HÀNH ĐỘNG 3
    spreadsheet = @service.get_spreadsheet(spreadsheet_id)
    clear_request_body = Google::Apis::SheetsV4::ClearValuesRequest.new
    @service.clear_values(spreadsheet_id, "#{rewrite_sheet_name}!A1:L1000", clear_request_body)

  end
end
