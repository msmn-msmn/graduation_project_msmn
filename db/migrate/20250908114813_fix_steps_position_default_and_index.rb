class FixStepsPositionDefaultAndIndex < ActiveRecord::Migration[7.2]
  def up
    # 1) 既存のユニーク複合インデックスを外す
    remove_index :steps, name: "index_steps_on_sub_task_id_and_position"

    # 2) position のデフォルトを 0 -> 1 に変更
    change_column_default :steps, :position, from: 0, to: 1

    # 3) 既存データの 0 を 1 に更新（ユニークを外した後にやるのが安全）
    execute "UPDATE steps SET position = 1 WHERE position = 0"

    # 4) 非ユニークの複合インデックスを作り直す
    add_index :steps, [ :sub_task_id, :position ], name: "index_steps_on_sub_task_id_and_position"
  end

  def down
    # 逆順で戻す（必要に応じて）
    remove_index :steps, name: "index_steps_on_sub_task_id_and_position"

    change_column_default :steps, :position, from: 1, to: 0

    # 元の値(0)に完全には戻せないので、ここでは変更しないか、必要なら個別対応してください
    add_index :steps, [ :sub_task_id, :position ],
              name: "index_steps_on_sub_task_id_and_position", unique: true
  end
end
