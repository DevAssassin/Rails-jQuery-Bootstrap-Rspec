class HomeController < ApplicationController
  skip_before_filter :set_user_state

  def index
    if mobile?
      redirect_to mobile_path
    elsif current_user
      redirect_to current_scope
    else
      redirect_to new_user_session_url
    end
  end
end
