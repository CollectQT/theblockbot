class SessionsController < ApplicationController

  def create
    session[:user_id] = Auth.parse(request.env["omniauth.auth"]).id
    redirect_to request.env["omniauth.origin"] || root_url, :notice => "Signed in!"
  end

  def destroy(notice="Signed out!")
    reset_session
    redirect_to request.env["HTTP_REFERER"] || root_url, :notice => notice
  end

  def failure
    logger.error env['omniauth.error'].inspect
    redirect_to request.env['omniauth.origin'] || root_url,
      :alert => "login failed"
  end

end
