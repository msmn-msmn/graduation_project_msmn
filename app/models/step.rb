class Step < ApplicationRecord
  belongs_to :user
  belongs_to :sub_task
  acts_as_list scope: :sub_task, column: :position, add_new_at: :bottom

  validates :name, presence: true
  validates :status, presence: true
  validates :position, presence: true

  before_validation :set_user_from_sub_task, on: :create

  # enum定義
  enum status: {
    not_started: 0,    # 未着手
    in_progress: 1,    # 進行中
    completed: 2,      # 完了
    on_hold: 3,        # 保留
    cancelled: 4       # キャンセル
  }



  private

  def set_user_from_sub_task
    self.user_id ||= sub_task&.user_id
  end
end
