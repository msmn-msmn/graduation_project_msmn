class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true
      t.text :description_for_ai                         # AI用説明文
      t.text :user_memo
      t.integer :status, default: 0, null: false         # 進行管理enum用
      t.integer :priority, default: 0, null: false       # 表示優先順位enum用
      t.integer :daily_task_time, null: false            # 1日のタスクに使える時間(分)
      t.integer :estimate_min_days, null: false          # 完了見積最短
      t.integer :estimate_normal_days, null: false       # 完了見積普通
      t.integer :estimate_max_days, null: false          # 完了見積最大
      t.integer :calculated_estimated_days               # 算出見積時間
      t.integer :work_time                               # 実際作業時間(分)
      t.datetime :due_date                               # タスクの締切日
      t.datetime :completed_at                           # タスクの完了日

      t.timestamps
    end
  end
end
