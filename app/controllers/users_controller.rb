class UsersController < ApplicationController

  def index
    redirect
  end

  def redirect
    if not current_user
      redirect_to '/auth/twitter'
    end
  end

end
