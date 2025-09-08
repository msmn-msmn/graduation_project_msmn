class AllowNullEstimatesForDrafts < ActiveRecord::Migration[7.2]
  def change
    change_column_null :tasks, :daily_task_time,      true
    change_column_null :tasks, :estimate_min_days,    true
    change_column_null :tasks, :estimate_normal_days, true
    change_column_null :tasks, :estimate_max_days,    true
  end
end
