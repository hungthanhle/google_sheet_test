class TimesheetCronsController < ApplicationController
  # http_basic_authenticate_with name: ENV["BASIC_AUTHEN_USER"], password: ENV["BASIC_AUTHEN_PASSWORD"]
  
  def accounts
    render json: {sucess: true, path: 'timesheet_crons/accounts'}
  end
end
