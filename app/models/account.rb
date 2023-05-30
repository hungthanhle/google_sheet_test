class Account < ApplicationRecord
  has_many :timesheets
  @@id_count = 0

  before_validation {
    (self.email = self.email.to_s.downcase)
    :set_uid
  }

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

  protected

  def password_required?
    false
  end

  private

  def set_uid
    self.uid = self.email
  end

end
