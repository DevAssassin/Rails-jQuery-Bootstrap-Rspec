class RulesController < ApplicationController
  set_tab :rules

  def index
    @programs = current_account.programs
  end
end
