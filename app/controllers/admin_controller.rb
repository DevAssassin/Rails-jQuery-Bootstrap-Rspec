class AdminController < ApplicationController
  prepend_before_filter :ensure_superuser!

  helper_method :current_program
  helper_method :current_account
  helper_method :current_scope

  def current_program
    Program.where(:_id => params[:program_id]).first
  end

  def current_account
    Account.where(:_id => params[:account_id]).first
  end

  def current_scope
    current_program || current_account
  end

  private
  def ensure_superuser!
    su = current_user && current_user.superuser?

    render 'public/404.html', :layout => false, :status => 404 unless su

    su
  end

end
