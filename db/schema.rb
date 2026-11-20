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

ActiveRecord::Schema[8.1].define(version: 2026_11_20_043047) do
  create_table "employees", force: :cascade do |t|
    t.string "employee_code"
    t.string "name"
    t.string "pin_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "timecards", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.date "work_date"
    t.datetime "clock_in"
    t.datetime "clock_out"
    t.integer "break_minutes"
    t.datetime "break_started_at"
    t.datetime "break_until"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_timecards_on_employee_id"
  end

  add_foreign_key "timecards", "employees"
end
