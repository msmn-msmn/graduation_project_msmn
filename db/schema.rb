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

ActiveRecord::Schema[7.2].define(version: 2025_09_03_162903) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "steps", force: :cascade do |t|
    t.bigint "sub_task_id", null: false
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.datetime "due_date"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_steps_on_status"
    t.index ["sub_task_id", "position"], name: "index_steps_on_sub_task_id_and_position", unique: true
    t.index ["sub_task_id"], name: "index_steps_on_sub_task_id"
    t.index ["user_id"], name: "index_steps_on_user_id"
  end

  create_table "sub_tasks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "task_id", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.integer "priority", default: 0, null: false
    t.integer "sub_work_time"
    t.datetime "sub_due_date"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority"], name: "index_sub_tasks_on_priority"
    t.index ["status"], name: "index_sub_tasks_on_status"
    t.index ["task_id"], name: "index_sub_tasks_on_task_id"
    t.index ["user_id"], name: "index_sub_tasks_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.text "description_for_ai"
    t.text "user_memo"
    t.integer "status", default: 0, null: false
    t.integer "priority", default: 0, null: false
    t.integer "daily_task_time", null: false
    t.integer "estimate_min_days", null: false
    t.integer "estimate_normal_days", null: false
    t.integer "estimate_max_days", null: false
    t.integer "calculated_estimated_days"
    t.integer "work_time"
    t.datetime "due_date"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "draft", default: true, null: false
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.integer "daily_available_time", default: 0, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "steps", "sub_tasks"
  add_foreign_key "steps", "users"
  add_foreign_key "sub_tasks", "tasks"
  add_foreign_key "sub_tasks", "users"
  add_foreign_key "tasks", "users"
end
