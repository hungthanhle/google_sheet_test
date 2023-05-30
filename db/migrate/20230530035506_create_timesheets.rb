class CreateTimesheets < ActiveRecord::Migration[6.1]
  def change
    create_table :timesheets do |t|
      t.string :account_id
      t.date :date
      t.timestamp :check_in
      t.timestamp :check_out
      t.float :work
      t.float :off
      t.date :compensation_day
      t.boolean :report
      t.string :message

      t.timestamps
    end
  end
end
