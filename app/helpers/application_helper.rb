module ApplicationHelper
  # ユーザーのメールアドレス変更メール未確認判定メソッド
  def show_pending_email_banner?
    user_signed_in? &&
    current_user.respond_to?(:pending_reconfirmation?) &&
    current_user.pending_reconfirmation? &&
    current_user.confirmation_period_valid?
  end
end
