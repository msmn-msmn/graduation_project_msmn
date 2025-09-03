class RemoveStepColumnsFromSubTasks < ActiveRecord::Migration[7.2]
  def change
    remove_column :sub_tasks, :step_name, :string
    remove_column :sub_tasks, :step_due_date, :datetime
    remove_column :sub_tasks, :step_completed_at, :datetime
  end
end
