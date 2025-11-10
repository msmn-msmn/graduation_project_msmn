class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show  destroy]

  def index
    @users = User.where(id: current_user.id)
  end

  def show
    # @user は before_action で設定済み
  end

  def destroy
  end

  private

  def set_user
    @user = current_user
  end
end
