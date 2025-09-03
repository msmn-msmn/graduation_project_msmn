class CreateSteps < ActiveRecord::Migration[7.2]
  def change
    create_table :steps do |t|
      t.references :sub_task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :status, default: 0, null: false
      t.integer :position, default: 0, null: false
      t.datetime :due_date
      t.datetime :completed_at
      t.timestamps
    end

    add_index :steps, [ :sub_task_id, :position ], unique: true
    add_index :steps, :status
  end
end
