class RenamePriorityToPositionInSubTasks < ActiveRecord::Migration[7.2]
  def up
    # ① priorityのインデックスを先に外す（この順番が安全）
    remove_index :sub_tasks, name: "index_sub_tasks_on_priority"

    # ② priorityカラムを削除（データは消えてOKという前提）
    remove_column :sub_tasks, :priority, :integer

    # ③ positionカラムを追加（acts_as_list向けに1始まり・NOT NULL）
    add_column :sub_tasks, :position, :integer, null: false, default: 1

    # ④ 並びや検索で使うなら、必要に応じて新しいインデックスを作成
    #    例: タスク内での順序取得を速くする複合インデックス
    add_index :sub_tasks, [:task_id, :position]
  end

  def down
    # upの逆順で戻せるようにしておく
    remove_index :sub_tasks, column: [:task_id, :position]

    remove_column :sub_tasks, :position, :integer

    add_column :sub_tasks, :priority, :integer, null: false, default: 0
    add_index :sub_tasks, :priority
  end
end