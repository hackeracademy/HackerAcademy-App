class PageController < ApplicationController
  skip_authorization_check

  def show
    render params[:name]
  end

  def redeem
    if current_user.nil?
      redirect_to new_user_session_path, alert: 'You need to log in first'
      return
    end
    first_cheevo = Achievement.first(conditions: {name: 'First Meeting!'})
    if params[:code].downcase.gsub(/\s+/, '') == 'purplellama'
      current_user.achievements << first_cheevo
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
