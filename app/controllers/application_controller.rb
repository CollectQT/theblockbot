class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  def new
    redirect_to '/auth/twitter'
  end

  def signin
    user = Auth.parse(request.env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_url, :notice => "Signed in!"
  end

  def signout
    session[:user_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end

  def failure
    redirect_to root_url, :notice => "Authentication error: #{params[:message].humanize}"
  end

  private
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
      signout
    end

end
