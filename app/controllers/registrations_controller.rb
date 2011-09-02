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

end
