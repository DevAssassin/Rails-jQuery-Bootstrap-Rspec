class Sport::Sailing < Recruit

  field :dominant_hand
  field :home_lane
  field :current_average
  field :last_years_average
  field :high_game
  field :high_series
  field :years_bowling_competitively
  field :games_bowled_per_week
  field :games_bowled_per_month
  
  # Team Fields
  field :plays_for_high_school_team, :type => Boolean, :default => false
  field :high_school_coach_name
  field :high_school_coach_phone, :type => MongoTypes::PhoneNumber
  field :high_school_coach_email
  field :high_school_schedule
  field :high_school_team_accomplishments
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

  def self.athletic_attributes
    [
      :dominant_hand,
      :home_lane,
      :current_average,
      :last_years_average,
      :high_game,
      :high_series,
      :years_bowling_competitively,
      :games_bowled_per_week,
      :games_bowled_per_month,
      :high_school_coach_name,
      :high_school_coach_phone,
      :high_school_coach_email,
      :high_school_schedule,
      :high_school_team_accomplishments,
      :club_name,
      :club_coach_name,
      :club_coach_phone,
      :club_coach_email,
      :club_schedule,
      :club_team_accomplishments,
      :other_teams,
      :other_teams_coach_info,
      :individual_accomplishments,
      :ncaa_clearinghouse_id,
      :other_sports_played
    ]
  end

end
