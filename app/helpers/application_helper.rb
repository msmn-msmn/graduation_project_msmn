module ApplicationHelper
  # ユーザーのメールアドレス変更メール未確認判定メソッド
  def show_pending_email_banner?
    return false unless user_signed_in?
    user = current_user

    # Deviseのreconfirmable: メール変更中か？
    return false unless user.respond_to?(:pending_reconfirmation?) &&
                        user.pending_reconfirmation?

    # トークンの有効期間内か？（リンクの有効性）
    return false if user.respond_to?(:confirmation_token_valid?) &&
                        user.confirmation_token_valid?

    current_user.unconfirmed_email.present?
  end

  # メール送信のレート制限（連打対策）
  def can_resend_confirmation_email?(user)
    cooldown_seconds = 300
    return true if user.confirmation_sent_at.blank?

    Time.current - user.confirmation_sent_at >= cooldown_seconds
  end

  # トークンの「有効期間内」かどうかを返す（true=期限内/有効）
  def confirmation_token_valid?(user)
    validity_period = Devise.confirm_within            # 例: 3.days / nil(無期限)
    return true if validity_period.nil?                # 無期限なら常に表示

    sent_at = user.confirmation_sent_at
    return false if sent_at.blank?                        # 送信記録の有無
    sent_at >= validity_period.ago                     # ← ここが「有効期間内」
  end
end
