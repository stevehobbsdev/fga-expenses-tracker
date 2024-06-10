# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.all
    @user_memo = @users.index_by(&:id)
  end

  def edit
    @user = User.find(params[:id])
    @managers = User.where(role: 'manager')
                    .filter { |m| m.id != @user.id && m.department_id == @user.department_id }
                    .collect { |m| [m.name, m.id] }

    @departments = Department.all.collect { |d| [d.name, d.id] }
  end

  def update
    User.transaction do
      user = User.find(params[:id])

      set_user_manager(user_id: user.id, manager_id: user_params[:manager_id])

      if user.department_id != user_params[:department_id]
        # Department has changed - update tuples for group memberships in FGA
      end

      user.update(user_params)
      if user.valid?
        redirect_to users_path
      else
        render :edit
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :role, :manager_id, :department_id)
  end
end
