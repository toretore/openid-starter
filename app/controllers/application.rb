# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'f484cfd407840dbe0f7d7a12432cdae5'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password


  helper_method :logged_in?
  def logged_in?
    !!current_user
  end


  helper_method :current_user
  def current_user
    @_current_user ||= User.find_by_id(session[:current_user_id])
  end


private

  #"Logging in":  self.current_user = a_user
  #"Logging out": self.current_user = nil
  def current_user=(user)
    session[:current_user_id] = user && user.id
    @_current_user = user
  end


end
