class TeamsController < ApplicationController
  def index
    @teams = Department.order(:name)
  end
end
