class StaticPagesController < ApplicationController
  def index
    # 既にログイン済みの場合はタスク一覧へ
    redirect_to tasks_path if user_signed_in?
  end
end
