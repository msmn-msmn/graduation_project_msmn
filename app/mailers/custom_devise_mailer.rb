class CustomDeviseMailer  < Devise::Mailer
  # 新規登録/変更 どちらでも呼ばれる
  def confirmation_instructions(record, token, opts = {})
    if record.respond_to?(:pending_reconfirmation?) && record.pending_reconfirmation?
      # プロフィールからのメールアドレス変更の確認
      opts[:template_name] = 'reconfirmation_instructions'     # 変更確認用テンプレート
      opts[:subject]       = I18n.t('devise.mailer.reconfirmation_instructions.subject')
    else
      # 通常の“新規登録”確認
      opts[:template_name] = 'reconfirmation_instructions'
    end
    super
  end

  # 旧メール宛のセキュリティ通知
  def email_changed(record, opts = {})
    if record.respond_to?(:unconfirmed_email?) && record.unconfirmed_email?
      # 申請受付（確認待ち）
      opts[:subject] = I18n.t('devise.mailer.email_change_requested.subject')
    end
    super
  end
end