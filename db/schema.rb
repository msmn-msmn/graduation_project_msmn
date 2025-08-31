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

ActiveRecord::Schema[7.2].define(version: 2025_08_31_075412) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "sub_tasks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "task_id", null: false
    t.string "name", null: false
    t.string "step_name"
    t.integer "status", default: 0, null: false                    # 進行管理enum用
    t.integer "priority", default: 0, null: false                  # 優先度enum用
    t.integer "sub_work_time"                                      # 実際作業時間
    t.datetime "sub_due_date"                                      # 小タスクの締切日
    t.datetime "completed_at"                                      # 小タスクの完了日
    t.datetime "step_due_date"                                     # 小タスクのステップの締切日
    t.datetime "step_completed_at"                                 # 小タスクのステップの完了日
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority"], name: "index_sub_tasks_on_priority"      # 優先度ソート用
    t.index ["status"], name: "index_sub_tasks_on_status"          # ステータス検索用
    t.index ["task_id"], name: "index_sub_tasks_on_task_id"
    t.index ["user_id"], name: "index_sub_tasks_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.text "description_for_ai"                                    # AI用説明文
    t.text "user_memo"
    t.integer "status", default: 0, null: false                    # 進行管理enum用
    t.integer "priority", default: 0, null: false                  # 優先順位enum用
    t.integer "daily_task_time", null: false                       # 1日のタスクに使える時間
    t.integer "estimate_min_days", null: false                     # 完了見積最短
    t.integer "estimate_normal_days", null: false                  # 完了見積普通
    t.integer "estimate_max_days", null: false                     # 完了見積最大
    t.integer "calculated_estimated_days"                          # 算出見積時間
    t.integer "work_time"                                          # 実際作業時間
    t.datetime "due_date"                                          # タスクの締切日
    t.datetime "completed_at"                                      # タスクの完了日
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "sub_tasks", "tasks"
  add_foreign_key "sub_tasks", "users"
  add_foreign_key "tasks", "users"
end
