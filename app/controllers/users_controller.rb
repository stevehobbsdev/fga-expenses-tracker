# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.all
    @user_memo = @users.index_by(&:id)
  end

  def edit
    @user = User.find(params[:id])
    @managers = User.where(role: 'manager')
                    .filter { |m| m.id != @user.id && m.team_id == @user.team_id }
                    .collect { |m| [m.name, m.id] }

    @teams = Team.all.collect { |d| [d.name, d.id] }
  end

  def update
    User.transaction do
      user = User.find(params[:id])
      set_user_manager(user_id: user.id, manager_id: user_params[:manager_id])

      if user_params[:team_id] && user.team_id != user_params[:team_id]
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
    params.require(:user).permit(:name, :role, :manager_id, :team_id)
  end
end
