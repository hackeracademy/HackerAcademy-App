class PageController < ApplicationController
  skip_authorization_check

  def show
    render params[:name]
  end
end
