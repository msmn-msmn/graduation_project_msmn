class Task < ApplicationRecord
  belongs_to :user
  has_many :sub_tasks, dependent: :destroy
  accepts_nested_attributes_for :sub_tasks, allow_destroy: true

  # 基本項目のバリデーション（常に適用）
  validates :name, presence: true, length: { minimum: 3, maximum: 50 }
  validates :description_for_ai, length: { maximum: 100 }, allow_blank: true
  validates :user_memo, length: { maximum: 200 }, allow_blank: true

  # 見積もり項目のバリデーション（breakdown後のみ適用）
  validates :daily_task_time, presence: true, numericality: { greater_than: 0, only_integer: true }, if: :estimates_required?
  validates :estimate_min_days, presence: true, numericality: { greater_than: 0 }, if: :estimates_required?
  validates :estimate_normal_days, presence: true, numericality: { greater_than: 0 }, if: :estimates_required?
  validates :estimate_max_days, presence: true, numericality: { greater_than: 0 }, if: :estimates_required?

  # カスタムバリデーション
  validate :estimate_days_logical_order
  validate :due_date_future



  # タスク作業状態
  enum status: {
  not_started: 0,    # 未着手
  in_progress: 1,    # 作業中
  completed: 2,      # 完了
  on_hold: 3,        # 保留
  cancelled: 4       # キャンセル
  }

  # タスク優先順位
  enum priority: {
  low: 0,      # 低
  medium: 1,   # 中
  high: 2,     # 高
  urgent: 3    # 緊急
  }

  # 見積もり項目のバリデーションが必要かどうかを判定
  attr_accessor :skip_estimates_validation

  scope :active, -> { where.not(status: [ :completed, :cancelled ]) }
  scope :overdue, -> { where("due_date < ? AND status != ?", Time.current, statuses[:completed]) }
  scope :due_soon, -> { where(due_date: Time.current..3.days.from_now) }

  # コールバック
  before_save :calculate_estimated_days
  after_update :update_completion_time, if: :saved_change_to_status?


  private

  def estimates_required?
    # skip_estimates_validation が true の場合はバリデーションをスキップ
    !skip_estimates_validation
  end

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

  # 締切日の論理チェック
  def due_date_future
    return if due_date.blank?

    if due_date < Time.zone.now
      errors.add(:due_date, "は現在時刻より未来である必要があります")
    end
  end

  def calculate_estimated_days
    # 三点見積もりの計算 (PERT法)
    # (最短 + 4×普通 + 最長) ÷ 6
    if estimate_min_days && estimate_normal_days && estimate_max_days
      self.calculated_estimated_days = (estimate_min_days + 4 * estimate_normal_days + estimate_max_days) / 6
    end
  end

  # 完了日時記録
  def update_completion_time
    update_column(:completed_at, completed? ? Time.current : nil)
  end
end
