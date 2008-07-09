class User < ActiveRecord::Base

  validates_presence_of :openid_url
  validates_uniqueness_of :openid_url


  def display_name
    name.blank? ? openid_url : name
  end


end
