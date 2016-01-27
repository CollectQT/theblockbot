class UsersController < ApplicationController

  # GET /profile
  def index
    if not current_user
      redirect_to '/auth/twitter'
    end
  end

  # GET /user/reports/?id=00000
  # GET /user/reports/?user_name=@cyrin
  def report
    # todo: make shorter
    if params[:id]
      @user = User.get(params[:id])
    elsif params[:user_name]
      @user = User.get(params[:user_name])
    else
      @user = nil
    end
  end

end
