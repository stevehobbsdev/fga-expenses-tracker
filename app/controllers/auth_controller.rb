# frozen_string_literal: true

class AuthController < ApplicationController
  include Authentication

  skip_before_action :verify_authenticity_token, only: :callback
  skip_before_action :check_session, only: :callback

  def login; end

  def logout; end

  def callback
    handle_auth_callback(params)
    redirect_to root_path
  end
end
