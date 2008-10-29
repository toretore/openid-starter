class LoginsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => :create


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

    #Add or update attributes provided by the OpenID server
    model_to_registration_mapping.each do |attr,reg_key|
      user.send("#{attr}=", registration[reg_key])
    end

    if user.save
      self.current_user = user#This is the actual "logging in"
      authentication_successful
    else
      authentication_failed 'Login failed: Could not save user from requested data'
    end
  end


  def openid_authentication_url
    params[:openid_identifier]
  end

  def openid_authentication_options(opts={})
   {
    :return_to => login_url #open_id_authentication will fake a POST
   }.merge(openid_registration_options).merge(opts)
  end

  #Which attributes to request from the provider using the Simple Registration Extension
  #They can be :optional or :required
  def openid_registration_options
    {:optional => [:fullname, :email]}
  end

  #Which attributes on the model receives which SReg attributes?
  def model_to_registration_mapping
    {:name => 'fullname', :email => 'email'}
  end


end
