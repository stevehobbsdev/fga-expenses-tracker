# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :check_session

  private

  def check_session
    Rails.logger.debug 'Session is not active'
  end
end
