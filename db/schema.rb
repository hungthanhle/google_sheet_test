# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_05_30_040428) do

  create_table "accounts", id: false, force: :cascade do |t|
    t.string "id", null: false
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "allow_password_change", default: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.integer "gender", null: false
    t.date "date_of_birth", null: false
    t.string "phone_number", null: false
    t.string "address", null: false
    t.integer "status", null: false
    t.integer "position", null: false
    t.integer "contract", null: false
    t.string "slack_token", null: false
    t.integer "role", null: false
    t.date "date", null: false
    t.string "identity_card", null: false
    t.date "date_of_issue"
    t.string "place_of_issue"
    t.text "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_accounts_on_uid_and_provider", unique: true
  end

  create_table "timesheets", force: :cascade do |t|
    t.string "account_id"
    t.date "date"
    t.datetime "check_in"
    t.datetime "check_out"
    t.float "work"
    t.float "off"
    t.date "compensation_day"
    t.boolean "report"
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
