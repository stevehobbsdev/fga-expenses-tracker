class TeamsController < ApplicationController
  def index
    @teams = Department.order(:name)
  end

  def edit
    @team = Department.find(params[:id])
  end
end
