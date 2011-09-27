class PageController < ApplicationController
  skip_authorization_check

  def show
    render params[:name]
  end

  # TODO: Fix this super-hacky solution to something that actually scales...
  def redeem
    if current_user.nil?
      redirect_to new_user_session_path, alert: 'You need to log in first'
      return
    end
    cheevo = Achievement.first(conditions: {name: 'Second Meeting!'})
    if params[:code].downcase.gsub(/\s+/, '') == 'skytaffy'
      current_user.achievements << cheevo
    else
      redirect_to "/redeem", alert: 'Sorry, invalid code :('
      return
    end
    if current_user.save
      redirect_to current_user, notice:  'Achievement unlocked!'
    else
      redirect_to "/redeem", alert: 'Sorry, try again'
    end
  end
end
