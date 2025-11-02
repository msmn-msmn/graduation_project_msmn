module ApplicationHelper
  # ユーザーのメールアドレス変更メール未確認判定メソッド
  def show_pending_email_banner?
    return false unless user_signed_in?
    user = current_user

    # Deviseのreconfirmable: メール変更中か？
    return false unless user.respond_to?(:pending_reconfirmation?) &&
                        user.pending_reconfirmation?

    # トークンの有効期間内か？（リンクの有効性）
    return false unless user.respond_to?(:confirmation_period_expired?) &&
                        user.confirmation_period_expired?
    current_user.unconfirmed_email.present?
  end

  # メール送信のレート制限（連打対策）
  def can_resend_confirmation_email?(user)
    cooldown_seconds = 300
    return true if user.confirmation_sent_at.blank?

    Time.current - user.confirmation_sent_at >= cooldown_seconds
  end
end
