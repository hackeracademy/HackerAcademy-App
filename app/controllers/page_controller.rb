class PageController < ApplicationController
  skip_authorization_check

  def show
    render params[:name]
  end

  def set_current
    if current_user.nil? or !current_user.is_admin?
      redirect_to '/', alert: 'Only admins allowed'
      return
    end
    old_curr = Achievement.where(current: true).first
    if !old_curr.nil?
      old_curr.current = false
      if !old_curr.save
        redirect_to '/set_current', alert: 'Unable to unset old current'
        return
      end
    end
    new_curr = Achievement.find(params[:achievement])
    new_curr.current = true
    new_curr.code = params[:code]
    if new_curr.save
      redirect_to '/redeem', notice: 'Code updated'
    else
      redirect_to '/set_current', alert: 'Failed to update achievement code'
    end
  end

  # TODO: Fix this super-hacky solution to something that actually scales...
  def redeem
    if current_user.nil?
      redirect_to new_user_session_path, alert: 'You need to log in first'
      return
    end
    cheevo = Achievement.current
    if params[:code].downcase.gsub(/\s+/, '') == cheevo.code
      current_user.achievements << cheevo
    else
      redirect_to '/redeem', alert: 'Sorry, invalid code :('
      return
    end
    if current_user.save
      redirect_to current_user, notice:  'Achievement unlocked!'
    else
      redirect_to '/redeem', alert: 'Sorry, try again'
    end
  end

  def rfid
    user = User.where(rfid: params[:rfid]).first
    if user.nil?
      redirect_to '/redeem', alert: 'Invalid rfid'
    else
      cheevo = Achievement.current
      user.achievements << cheevo
      if user.save
        redirect_to '/redeem', notice: "Achievement granted to #{user.name}"
      else
        redirect_to '/redeem', alert: 'Failed to grant achievement'
      end
    end
  end

end
