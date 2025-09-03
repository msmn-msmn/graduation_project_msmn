class AddDraftToTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :tasks, :draft, :boolean, null: false, default: true
  end
end
