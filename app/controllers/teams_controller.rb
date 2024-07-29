# frozen_string_literal: true

class TeamsController < ApplicationController
  def index
    @teams = Team.order(:name)
  end

  def new
    @team = Team.new
  end

  def edit
    @team = Team.find(params[:id])
  end

  def create
    @team = Team.create(team_params)

    # Adjust FGA tuples depending on the value of :expense_approver
    # - add this team to all expenses as approver

    redirect_to action: :index if @team.valid?
  end

  def update
    @team = Team.find(params[:id])
    @team.update(team_params)

    # Adjust FGA tuples depending on the value of :expense_approver
    # - if value has changed (now true) add to all expenses
    # - if value has changed (now false) remove from all expenses

    redirect_to action: :index if @team.valid?
  end

  def destroy
    Team.delete(params[:id])

    # Adjust FGA tuples depending on the value of :expense_approver

    redirect_to action: :index
  end

  private

  def team_params
    params.require(:team).permit(:name, :expense_approver)
  end
end
