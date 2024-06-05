# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication

  before_action :check_session

  private

  def check_session
    return do_login unless logged_in?

    @session = user_session
    @user = User.find_by(sub: @session)
  end
end
