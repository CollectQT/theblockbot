class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  def new
    redirect_to '/auth/twitter'
  end

  def signin
    user = Auth.parse(request.env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to request.env['omniauth.origin'] || root_url, :notice => "Signed in!"
  end

  def signout(notice="Signed out!")
    reset_session
    redirect_to redirect_to_back, :notice => notice
  end

  def failure
    redirect_to request.env['omniauth.origin'] || :back || root_url, :notice => "Authentication error: #{params[:message].humanize}"
  end

  private
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
      signout("A login error occured, you have been signed out")
    end

    def redirect_to_back(default = root_url)
      if request.env["HTTP_REFERER"].present? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
        redirect_to :back
      else
        redirect_to default
      end
    end
end
