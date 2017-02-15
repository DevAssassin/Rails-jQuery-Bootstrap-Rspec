class ScopeController < ApplicationController
  def change
    kind, id = params[:scope].split("|")

    new_scope = find_scope(kind, id)

    if new_scope
      session[:scope_id] = new_scope.id
      session[:scope_type] = new_scope.class.to_s
    end

    redirect_to root_url
  end

  private

  def find_scope(kind, id)
    case kind
    when "Account"
      current_user.find_scoped_accounts(id)
    when "Program"
      current_user.find_scoped_programs(id)
    end
  end
end
