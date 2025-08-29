class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller? # Deviseのコントローラであるときだけ実行する

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username ]) # ユーザー登録(sign_up)時に username を許容する
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username ]) # ユーザーのプロフィール更新(account_update)時にも username を 許容する
  end

   # ログイン後のリダイレクト先
  def after_sign_in_path_for(resource)
    # ログイン前にアクセスしようとしたページがあれば優先
    stored_location_for(resource) || tasks_path
  end
end
