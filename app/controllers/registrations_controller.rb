require 'net/http'

class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    res = Net::HTTP.post_form(
      URI.parse('http://tinyletter.com/hackeracademy'), {
      :emailaddress => params['user']['email'],
      :embed => 1
    })
    super
  end

  def update
    super
  end

  def quick_signup_page
    build_resource({})
    render :quick_signup
  end

  def quick_signup
    build_resource
    if resource.save
      set_flash_message :notice, :signed_up
    else
      set_flash_message :alert, :signup_failed
    end
    redirect_to dosignup_path
  end

end
