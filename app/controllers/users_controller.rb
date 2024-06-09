# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.all
    @user_memo = @users.index_by(&:id)
  end
end
