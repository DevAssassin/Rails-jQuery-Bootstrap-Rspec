class Sport::Wrestling < Recruit

  field :projected_college_weight
  field :dominant_hand
  field :freestyle_tournament_results
  field :greco_roman_tournament_results

  # Team Info
  field :plays_for_high_school_team, :type => Boolean, :default => false
  field :high_school_weight_class
  field :high_school_coach_name
  field :high_school_coach_phone, :type => MongoTypes::PhoneNumber
  field :high_school_coach_email
  field :high_school_schedule
  field :high_school_team_accomplishments
  field :senior_record
  field :senior_weight
  field :senior_state_place
  field :junior_record
  field :junior_weight
  field :junior_state_place
  field :sophomore_record
  field :sophomore_weight
  field :sophomore_state_place
  field :freshman_record
  field :freshman_weight
  field :freshman_state_place
  field :plays_for_club_team, :type => Boolean, :default => false
  field :club_coach_name
  field :club_coach_phone, :type => MongoTypes::PhoneNumber
  field :club_coach_email
  field :club_schedule
  field :club_team_accomplishments
  field :plays_for_other_team, :type => Boolean, :default => false
  field :other_teams
  field :other_teams_coach_info

  DominantHandTypes = %w{Right Left}
  HSWeightClasses = %w{103 112 119 125 130 135 140 145 152 160 171 189 215 275}
  CollegeWeightClasses = %w{125 133 141 149 157 165 174 184 197 285}

  def self.athletic_attributes
    [
      :projected_college_weight,
      :dominant_hand,
      :freestyle_tournament_results,
      :greco_roman_tournament_results,
      :plays_for_high_school_team,
      :high_school_weight_class,
      :high_school_coach_name,
      :high_school_coach_phone,
      :high_school_coach_email,
      :high_school_schedule,
      :high_school_team_accomplishments,
      :senior_record,
      :senior_weight,
      :senior_state_place,
      :junior_record,
      :junior_weight,
      :junior_state_place,
      :sophomore_record,
      :sophomore_weight,
      :sophomore_state_place,
      :freshman_record,
      :freshman_weight,
      :freshman_state_place,
      :plays_for_club_team,
      :club_name,
      :club_coach_name,
      :club_coach_phone,
      :club_coach_email,
      :club_schedule,
      :club_team_accomplishments,
      :plays_for_other_team,
      :other_teams,
      :other_teams_coach_info,
      :individual_accomplishments,
      :ncaa_clearinghouse_id,
      :other_sports_played
    ]
  end

end
