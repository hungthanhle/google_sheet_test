class GoogleSheetsController < ApplicationController
  # client = Google::Apis::SheetsV4::SheetsService.new
  def index
  end
  
  def create
    GoogleSheetsService.new.insert
    render json: {ok: true}
  end
end
