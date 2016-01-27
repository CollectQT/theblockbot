class UsersController < ApplicationController

  # GET /profile
  def index
    if not current_user
      redirect_to '/auth/twitter'
    end
  end

  # GET /user/reports/?id=00000
  # GET /user/reports/?user_name=@cyrin
  def reports
    # todo: make shorter
    begin
      if params[:id]
        @user = User.find(params[:id])
      elsif params[:account_id]
        @user = User.get(params[:account_id])
      elsif params[:user_name]
        @user = User.get(params[:user_name])
      else
        @user = nil
      end
    rescue ActiveRecord::RecordNotFound, Twitter::Error::NotFound
      @user = nil
    end
  end

end
