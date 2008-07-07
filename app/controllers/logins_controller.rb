class LoginsController < ApplicationController


  def show
    redirect_to new_login_url unless logged_in?
  end


  def new
    redirect_to login_url if logged_in?
  end


  def create
    openid_authentication
  end


  def destroy
    self.current_user = nil
    flash[:notice] = 'Logged out'
    redirect_to root_url
  end


private

  def openid_authentication
    authenticate_with_open_id openid_authentication_url, openid_authentication_options do |result, identity_url, registration|
      if result.successful?
        authenticate_openid_user(identity_url, registration)
      else
        authentication_failed result.message
      end
    end
  end


  def authentication_successful(message = 'Logged in')
    flash[:notice] = message
    redirect_to root_url
  end

  def authentication_failed(message = 'Login failed')
    flash.now[:error] = message
    render :action => 'new'
  end


  def authenticate_openid_user(identity_url, registration)
    user = User.find_or_initialize_by_openid_url(identity_url)
    model_to_registration_mapping.each do |attr,reg_key|
      user.send("#{attr}=", registration[reg_key]) unless registration[reg_key].blank?
    end

    if user.save
      self.current_user = user
      authentication_successful
    else
      authentication_failed 'Login failed: Could not save user from requested data'
    end
  end


  def openid_authentication_url
    params[:openid_url]
  end

  def openid_authentication_options(opts={})
   {
    :return_to => complete_login_url
   }.merge(openid_registration_options).merge(opts)
  end

  def openid_registration_options
    {:optional => [:fullname, :email]}
  end

  def model_to_registration_mapping
    {:name => 'fullname', :email => 'email'}
  end


end
