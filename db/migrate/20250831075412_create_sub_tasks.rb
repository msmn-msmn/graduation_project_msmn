class CreateSubTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :sub_tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :task, null: false, foreign_key: true
      t.string :name, null: false
      t.string :step_name
      t.integer :status, default: 0, null: false
      t.integer :priority, default: 0, null: false
      t.integer :sub_work_time
      t.datetime :sub_due_date
      t.datetime :completed_at
      t.datetime :step_due_date
      t.datetime :step_completed_at

      t.timestamps
    end

    add_index :sub_tasks, :status            # ステータス検索用
    add_index :sub_tasks, :priority          # 優先度ソート用
  end
end
