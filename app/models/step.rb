class Step < ApplicationRecord
  belongs_to :user
  belongs_to :sub_task

  validates :name, presence: true
  validates :status, presence: true
  validates :position, presence: true

  # enum定義
  enum status: {
    not_started: 0,    # 未着手
    in_progress: 1,    # 進行中
    completed: 2,      # 完了
    on_hold: 3,        # 保留
    cancelled: 4       # キャンセル
  }

  enum position: {
    first_row: 0,      # 1段目
    second_row: 1,     # 2段目
    third_row: 2      # 3段目
  }
end
