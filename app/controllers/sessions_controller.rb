class SessionsController < ApplicationController

  alias_method :create, :signin
  alias_method :destroy, :signout

end
