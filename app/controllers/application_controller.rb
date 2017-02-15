class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  before_filter :check_mobile!
  protect_from_forgery

  before_filter :set_user_state,  :unless => lambda { |c| c.devise_controller? }
  before_filter :set_user_time_zone

  helper :application
  include ApplicationHelper

  def set_user_state
    set_user_program
    set_user_account
    set_user_scope
    log_user_state
  end

  def log_user_state
    request.env['exception_notifier.exception_data'] = {
      :program => current_program,
      :account => current_account,
      :scope => current_scope,
      :user => current_user
    }
  end

  def set_user_program
    current_user.program = current_program
  end

  def set_user_account
    current_user.account = current_account
  end

  def set_user_scope
    current_user.scope = current_scope
  end

  def set_user_time_zone
    Time.zone = current_user.time_zone if current_user && !current_user.time_zone.blank?
  end

  def mobile_agent?
    request.user_agent =~ /Mobile|webOS/
  end

  def mobile?
    case
    when !params[:mobile].nil?
      params[:mobile] == "true"
    when !session[:mobile].nil?
      session[:mobile]
    else
      mobile_agent?
    end
  end

  def check_mobile!
    session[:mobile] = mobile?
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

end
