class ApiController < ApplicationController
  layout :false
  before_filter :authenticate_user!, unless: Proc.new {true}
  before_filter :set_user_state, unless: Proc.new {true}

  def recruit
    recruit = Recruit.find params[:id]
    if recruit
      render json: recruit.nonblank_visible_attributes.merge(
        {
          sport_name: recruit.sport_name,
          athletic_attributes: recruit.nonblank_athletic_attributes,
          school_name: recruit.school_name,
          program_name: recruit.program_name
        }
      )
    else
      render status: 404
    end
  end
end