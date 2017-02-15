module CoachesHelper
  def coach_form(institution, coach, &block)
    if coach.new_record?
      semantic_form_for(coach, :url => institution_coaches_url(institution), &block)
    else
      semantic_form_for(coach, :url => institution_coach_url(institution, coach), &block)
    end
  end
end
