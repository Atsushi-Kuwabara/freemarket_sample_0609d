class UsersController < ApplicationController
  before_action :set_user, only: :show

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
  def set_user
    @user = User.find(current_user.id)
  end
end
