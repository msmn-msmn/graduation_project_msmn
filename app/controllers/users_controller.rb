class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.where(id: current_user.id)
  end

  def show
    # @user は before_action で設定済み
  end

  def edit
    # @user は before_action で設定済み
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "プロフィールを更新しました"
    else
      render :edit
    end
  end

  def destroy
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:username, :daily_available_time)
  end
end
