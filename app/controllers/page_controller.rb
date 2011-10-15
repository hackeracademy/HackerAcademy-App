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
    cheevo = Achievement.first(conditions: {name: 'Dojo 1 Participant'})
    if params[:code].downcase.gsub(/\s+/, '') == 'haystacks'
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
