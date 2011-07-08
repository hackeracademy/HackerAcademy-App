class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :check_permissions, :only => [:update]

  def check_permissions
    authorize! :update, resource
  end
end
