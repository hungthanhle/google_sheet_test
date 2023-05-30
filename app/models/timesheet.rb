class Timesheet < ApplicationRecord
  TOTAL_HALF_WORKING_MINUTES = 60 * 4
  MAX_LATE_OR_EARLY_MINUTES = 60 * 2

  belongs_to :account

  validates :date, presence: true
  validate :daily_report_validate, on: :get_daily_report

  scope :by_date, -> (month, year) do
    where('MONTH(date) = ? AND YEAR(date) = ?', month, year)
  end
  scope :come_in_late, -> do
    where("cast(check_in as time) > ?", Settings.timesheets.checkin)
  end
  scope :leave_early, -> do
    where("cast(check_out as time) < ?", Settings.timesheets.checkout)
  end
  scope :no_data, -> do
    where("(check_in IS NULL OR check_out IS NULL) AND date <> CURDATE()")
  end
  scope :week_days, -> do
    where("DAYOFWEEK(date) <> 1 AND DAYOFWEEK(date) <> 7")
  end

  def daily_report_validate
    errors.add(:message, "errors.messages.daily_report_nil") if self.report.nil?
  end

  def calculate_work_time
    work = 0
    off = 8

    if check_in.present? && check_out.present?
      missing_minutes = missing_morning_minutes(check_in, check_out) + missing_afternoon_minutes(check_in, check_out)
      work = 8 - (missing_minutes / 60.0)
      off = 8 - work
    end
    [work, off]
  end

  private

  def missing_morning_minutes check_in_time, check_out_time
    missing_minutes = 0
    default_morning_checkin_time = Time.zone.parse("#{date} 8:05")
    default_morning_checkout_time = Time.zone.parse("#{date} 12:05")

    return TOTAL_HALF_WORKING_MINUTES if check_in_time >= default_morning_checkout_time

    # calculate missing minute for late morning checkin
    actual_morning_checkin_time = [default_morning_checkin_time, check_in_time].max
    missing_minutes += (((actual_morning_checkin_time - default_morning_checkin_time) / 60.0) / 30.0).ceil * 30

    # calculate missing minute for early morning checkout
    actual_morning_checkout_time = [default_morning_checkout_time, check_out_time].min
    missing_minutes += (((default_morning_checkout_time - actual_morning_checkout_time) / 60.0) / 30.0).ceil * 30

    return TOTAL_HALF_WORKING_MINUTES if missing_minutes > MAX_LATE_OR_EARLY_MINUTES

    missing_minutes
  end

  def missing_afternoon_minutes check_in_time, check_out_time
    missing_minutes = 0
    default_afternoon_checkin_time = Time.zone.parse("#{date} 13:05")
    default_afternoon_checkout_time = Time.zone.parse("#{date} 17:05")

    return TOTAL_HALF_WORKING_MINUTES if check_out_time <= default_afternoon_checkin_time

    # calculate missing minute for late afternoon checkin
    actual_afternoon_checkin_time = [default_afternoon_checkin_time, check_in_time].max
    missing_minutes += (((actual_afternoon_checkin_time - default_afternoon_checkin_time) / 60.0) / 30.0).ceil * 30

    # calculate missing minute for early afternoon checkout
    actual_afternoon_checkout_time = [default_afternoon_checkout_time, check_out_time].min
    missing_minutes += (((default_afternoon_checkout_time - actual_afternoon_checkout_time) / 60.0) / 30.0).ceil * 30

    return TOTAL_HALF_WORKING_MINUTES if missing_minutes > MAX_LATE_OR_EARLY_MINUTES

    missing_minutes
  end
end
