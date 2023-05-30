class SyncDataTimeKeeperService
  UPDATED_COLUMNS = %i[check_in check_out work off] # column of Timesheet table < database
  # this table is modified by MÁY CHẤM CÔNG ? <<<--- SAI

  attr_accessor :date

  def initialize date: Date.current, timekeeper_data: {}
    @date = date
    # BẮN POST LÊN: GỒM time_in, time_out
    @timekeeper_data = timekeeper_data
  end

  def perform
    created_timesheets = []
    new_timesheets = []

    # Account.staff.active # Account.all
    accounts.each do |account|
      # Timesheet.where(date: date)
      # Timesheet.where(date: date).find(account.id)
      time_sheet = today_timesheet_by_account(account.id)
      if time_sheet.present?
        # With date and account SET
        # checkin = "#{date} #{@timekeeper_data.dig(account_id.to_s, "time_in")}"
        # checkout = "#{date} #{@timekeeper_data.dig(account_id.to_s, "time_out")}"
        # lấy từ @timekeeper_data BẮN POST LÊN
        created_timesheets << init_time_sheets(time_sheet)
      else
        # create new timesheet
        new_timesheet = account.timesheets.new
        new_timesheets << init_time_sheets(new_timesheet)
      end
    end
    Timesheet.import new_timesheets
    Timesheet.import created_timesheets, on_duplicate_key_update: UPDATED_COLUMNS
  end

  private

  def accounts
    @accounts ||= Account.staff.active
  end

  def today_time_sheets
    @today_time_sheets ||= Timesheet.where(date: date)
  end

  def today_timesheet_by_account account_id
    today_time_sheets.find do |timesheet|
      timesheet.account_id == account_id
    end
  end

  def timekeeper_data_by_account account_id
    # timekeeper_data
    return [nil, nil] if @timekeeper_data.blank?

    checkin = if @timekeeper_data.dig(account_id.to_s, "time_in").present?
      Time.zone.parse("#{date} #{@timekeeper_data.dig(account_id.to_s, "time_in")}")
    else
      nil
    end
    checkout = if @timekeeper_data.dig(account_id.to_s, "time_out").present?
      Time.zone.parse("#{date} #{@timekeeper_data.dig(account_id.to_s, "time_out")}")
    else
      nil
    end
    [checkin, checkout]
  end

  def init_time_sheets time_sheet
    checkin, checkout = timekeeper_data_by_account(time_sheet.account_id)
    
    # save this checkin, checkout to database with account's id
    time_sheet.check_in = checkin.beginning_of_minute if checkin.present?
    time_sheet.check_out = checkout.end_of_minute if checkout.present?
    time_sheet.date = date

    # another field value
    work, off = time_sheet.calculate_work_time
    time_sheet.work = work
    time_sheet.off = off

    time_sheet
  end
end
