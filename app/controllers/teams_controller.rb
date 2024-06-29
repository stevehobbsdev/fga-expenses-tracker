# frozen_string_literal: true

class TeamsController < ApplicationController
  def index
    @teams = Team.order(:name)
  end

  def edit
    @team = Team.find(params[:id])
  end
end
