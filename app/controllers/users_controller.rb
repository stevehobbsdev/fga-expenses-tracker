# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.all
    @user_memo = @users.index_by(&:id)
  end
  
  def edit
    @user = User.find(params[:id])
    @possible_managers = User.where(role: 'manager')
  end

  def update
    user = User.find(params[:id])
    user.update(user_params)

    if user.valid?
      redirect_to users_path
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :role, :manager_id)
  end
end
