class SessionsController < ApplicationController

  def new
    redirect_to '/auth/twitter'
  end

  def create
    user = Auth.parse(request.env["omniauth.auth"])
    session[:user_id] = user.id
    path = request.env['omniauth.origin'] || root_url
    logger.debug { "Request redirect back path: #{path}" }
    redirect_to path, :notice => "Signed in!"
  end

  def destroy(notice="Signed out!")
    reset_session
    redirect_to redirect_to_back, :notice => notice
  end

  def failure
    logger.error env['omniauth.error'].inspect
    begin
        notice = "Authentication error: #{params[:message].humanize}"
    rescue NoMethodError
        notice = "Authentication error!"
    end
    redirect_to request.env['omniauth.origin'] || :back || root_url, :notice => notice
  end

  private
    def redirect_to_back(default = root_url)
      if request.env["HTTP_REFERER"].present? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
        :back
      else
        default
      end
    end

end
