class Account < ApplicationRecord
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :overtimes
  has_many :dayoffs
  has_many :timesheets
  has_many :compensations
  @@id_count = 0
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User
  include PasswordValidation
  include InstructionMailerHelper
  before_validation {
    (self.email = self.email.to_s.downcase)
    :set_uid
  }
  after_create :send_email_init_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: true }, format: { with: Devise.email_regexp }

  enum gender: {
    male: 0,
    female: 1,
    gender_other: 2
  }

  enum status: {
    active: 0,
    inactive: 1
  }

  enum position: {
    board_of_director: 0,
    back_office: 1,
    comtor: 2,
    developer: 3,
    tester: 4,
    position_other: 5
  }

  enum contract: {
    fulltime: 0,
    parttime: 1,
    probation: 2,
    intern: 3
  }

  enum role: {
    admin: 0,
    staff: 1
  }

  def can_modify_account?(account_id)
    self.admin? || id.to_s == account_id.to_s
  end

  def self.generate_staff_id
   last_id = Account.last ? Account.last.id.split("B").last.to_i : 0
   "B#{last_id.next.to_s.rjust(6, "0")}"
  end

  def self.get_id_count
    @@id_count
  end

  def first_checkin_time date
    first_checkin_time = timesheets.where('DATE(timesheets.date) = ?', date).minimum(:check_in)
  end

  def last_checkout_time date 
    last_checkout_time = timesheets.where('DATE(timesheets.date) = ?', date).maximum(:check_out)
  end

  def late_checkin_minutes date 
    check_in = first_checkin_time(date)
    default_checkin_time = Time.zone.parse("#{date} 8:05")
    default_checkout_time = Time.zone.parse("#{date} 17:05")
    # MATH: a < x < b
    return nil if check_in.nil? || check_in >= default_checkout_time
    actual_checkin_time = [default_checkin_time, check_in].max
    missing_minutes = ((actual_checkin_time - default_checkin_time) / 60).floor
  end

  def early_checkout_minutes date
    check_out = last_checkout_time(date)
    default_checkin_time = Time.zone.parse("#{date} 8:05")
    default_checkout_time = Time.zone.parse("#{date} 17:05")
    # MATH: a < x < b
    return nil if check_out.nil? || check_out <= default_checkin_time
    actual_checkout_time = [default_checkout_time, check_out].min
    missing_minutes = ((default_checkout_time - actual_checkout_time) / 60).ceil
  end

  protected

  def password_required?
    false
  end

  private

  def set_uid
    self.uid = self.email
  end

  def send_email_init_password
    send_reset_password_instructions(
      email: email,
      provider: "email",
      redirect_url: ENV["CLIENT_BASE_URL"],
    )
  end
end
