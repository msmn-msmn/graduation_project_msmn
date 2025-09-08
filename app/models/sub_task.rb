class SubTask < ApplicationRecord
  belongs_to :user
  belongs_to :task
  has_many :steps, dependent: :destroy
  accepts_nested_attributes_for :steps, allow_destroy: true
  acts_as_list scope: :task, column: :position, add_new_at: :bottom

  validates :name, presence: true, length: { maximum: 255 }
  validates :sub_work_time, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true


  validate :belongs_to_same_user
  validate :sub_due_date_not_in_past

  before_validation :set_user_from_task, on: :create

  # enum定義
  enum status: {
    not_started: 0,    # 未着手
    in_progress: 1,    # 進行中
    completed: 2,      # 完了
    on_hold: 3,        # 保留
    cancelled: 4       # キャンセル
  }


  # スコープ
  scope :by_priority, -> { order(:priority) }
  scope :by_due_date, -> { order(:sub_due_date) }
  scope :pending, -> { where(status: [ :not_started, :in_progress, :on_hold ]) }
  scope :overdue, -> { where("sub_due_date < ? AND status != ?", Time.current, statuses[:completed]) }

  # コールバック
  before_save :set_completed_at, if: :will_save_change_to_status?
  before_save :clear_completed_at, unless: :completed?

  # インスタンスメソッド
  def overdue?
    sub_due_date < Date.current && !completed?
  end

  def days_until_due
    return nil unless sub_due_date
    (sub_due_date - Date.current).to_i
  end

  def progress_percentage
    return 0 unless completed?
    100
  end

  private

  # カスタムバリデーション：同じユーザーに属するタスクかチェック
  def belongs_to_same_user
    return unless task && user

    if task.user_id != user_id
      errors.add(:task, "は同じユーザーのタスクである必要があります")
    end
  end

  # カスタムバリデーション：期限日が過去でないかチェック
  def sub_due_date_not_in_past
    return unless sub_due_date

    if sub_due_date < Date.current
      errors.add(:sub_due_date, "は今日以降の日付を設定してください")
    end
  end

  def set_user_from_task
    self.user ||= task&.user
  end

  # コールバック：完了時刻を設定
  def set_completed_at
    if status_changed? && completed?
      self.completed_at = Time.current
    end
  end

  # コールバック：完了時刻をクリア
  def clear_completed_at
    self.completed_at = nil if completed_at.present?
  end
end
