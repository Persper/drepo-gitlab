class DrepoUsersController < ApplicationController
  skip_before_action :drepo_check_username_verification
  before_action :set_user
  before_action :check_username_verified

  def check_username
  end

  def verified
    username = params[:drepo_users][:username]
    return unless username || username == 'root'

    @user.is_username_verified = true
    @user.username = username

    if @user.save
      redirect_to root_path
    else
      redirect_to drepo_check_username_path
    end
  end

  private

  def set_user
    @user = current_user
  end

  def check_username_verified
    return unless current_user

    if current_user.username == 'root' || current_user.is_username_verified
      redirect_to root_path
    end
  end
end
