class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, only: [:edit, :update, :destroy]

  protected

  # パスワード変更を含む更新時、current_passwordを要求する
  def update_resource(resource, params)
    if params[:password].present?
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

  def after_update_path_for(resource)
    users_path # プロフィール画面へ遷移
  end
end
