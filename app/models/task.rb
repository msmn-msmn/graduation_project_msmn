class Task < ApplicationRecord
  belongs_to :user
  
  # タスク作業状態
  enum status: { 
  not_started: 0,    # 未着手
  in_progress: 1,    # 作業中
  completed: 2,      # 完了
  on_hold: 3         # 保留
  }
  
  # タスク優先順位
  enum priority: { 
  low: 0,      # 低
  medium: 1,   # 中
  high: 2,     # 高
  urgent: 3    # 至急
  }
  
  validates :name, presence: true, length: { minimum: 3, maximum: 50 }
  validates :daily_task_time, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :estimate_min_days, presence: true, numericality: { greater_than: 0 }
  validates :estimate_normal_days, presence: true, numericality: { greater_than: 0 }
  validates :estimate_max_days, presence: true, numericality: { greater_than: 0 }
  validates :description_for_ai, length: { maximum: 100 }, allow_blank: true
  validates :user_memo, length: { maximum: 200 }, allow_blank: true

  validate :estimate_days_logical_order
  
  private
  
  # 見積もり日数の論理チェック
  def estimate_days_logical_order
    return unless estimate_min_days && estimate_normal_days && estimate_max_days
    
    if estimate_min_days > estimate_normal_days
      errors.add(:estimate_normal_days, "は最短日数以上である必要があります")
    end
    
    if estimate_normal_days > estimate_max_days
      errors.add(:estimate_max_days, "は普通日数以上である必要があります")
    end
  end
end