class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, only: [ :edit, :update, :destroy ]

  protected

  # プロフ＆パスワード両対応のアップデート処理
  def update_resource(resource, params)
    if params[:password].present?
      # パスワード変更を含む場合：現在のパスワード必須
      resource.update_with_password(params)
    else
      # パスワード以外の変更は current_password なしで許可
      resource.update_without_password(params)
    end
  end

  def account_update_params
    params.require(:user).permit(
      :username,
      :daily_available_time,
      :email,
      :password,
      :password_confirmation,
      :current_password
    )
  end

  # 更新成功後の遷移先（プロフ詳細へ）
  def after_update_path_for(resource)
    users_path
  end
end
