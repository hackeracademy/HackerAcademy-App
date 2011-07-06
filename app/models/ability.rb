class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.is_admin
      can :manage, :all
    else
      can :read, :all
      can :update, User, :_id => user._id
    end
  end
end
