class SessionsController < ApplicationController

  def create
    user = Auth.parse(request.env["omniauth.auth"])
    session[:user_id] = user.id
    path = set_path(request.referrer || root_url)
    puts "REDIRECT PATH: #{path}"
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

    def set_path(path)
      parts = path.split('/', 2)
      if parts.length.equal? 1
        return parts[0]
      else
        if parts[1].starts_with? 'signin'
          return parts[0]
        else
          return parts[0] + '/' + parts[1]
        end
      end
    end

end
