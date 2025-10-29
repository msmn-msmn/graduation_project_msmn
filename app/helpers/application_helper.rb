module ApplicationHelper
  # ユーザーのメールアドレス変更メール未確認判定メソッド
  def show_pending_email_banner?
    user_signed_in? &&
      current_user.respond_to?(:pending_reconfirmation?) &&
      current_user.pending_reconfirmation? &&
      current_user.respond_to?(:confirmation_period_valid?) &&
      current_user.confirmation_period_valid?
      current_user.unconfirmed_email.present?
  end

  # メール送信のレート制限（連打対策）
  def can_resend_confirmation_email?(user)
    cooldown_seconds = 300
    return true if user.confirmation_sent_at.blank?

    Time.current - user.confirmation_sent_at >= cooldown_seconds
  end
end
