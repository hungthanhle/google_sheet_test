class TimesheetCronsController < ApplicationController
  # http_basic_authenticate_with name: ENV["BASIC_AUTHEN_USER"], password: ENV["BASIC_AUTHEN_PASSWORD"]
  
  def accounts
    render json: {sucess: true, path: 'timesheet_crons/accounts'}
  end

  # POST  /timesheet_crons/import_data?date=&timekeeper_data=
  def import_data
    SyncDataTimeKeeperService.new(date: params[:date].to_date, timekeeper_data: JSON.parse(params[:timekeeper_data])).perform

    render json: {
      success: true
    }
  end
end
