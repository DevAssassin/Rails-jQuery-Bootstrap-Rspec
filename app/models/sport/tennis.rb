class Sport::Tennis < Recruit

  field :projected_position
  field :secondary_position
  field :dominant_hand
  field :game_type
  field :state_ranking
  field :usta_sectional_ranking
  field :usta_national_ranking
  field :other_rankings
  field :playing_style

  # Team Fields
  field :plays_for_high_school_team, :type => Boolean, :default => false
  field :high_school_position
  field :high_school_coach_name
  field :high_school_coach_phone, :type => MongoTypes::PhoneNumber
  field :high_school_coach_email
  field :high_school_schedule
  field :high_school_team_accomplishments
  field :plays_for_club_team, :type => Boolean, :default => false
  field :club_position
  field :club_coach_name
  field :club_coach_phone, :type => MongoTypes::PhoneNumber
  field :club_coach_email
  field :club_schedule
  field :club_team_accomplishments
  field :plays_for_other_team, :type => Boolean, :default => false
  field :other_teams
  field :other_teams_coach_info

  Positions = ["Unknown","1 Single","2 Single","3 Single","4 Single","5 Single","6 Single","1 Double","2 Double","3 Double"]
  DominantHandTypes = %w{Right Left}
  GameTypes = %w{Singles Doubles Both}

  def self.athletic_attributes
    [
      :projected_position,
      :secondary_position,
      :dominant_hand,
      :game_type,
      :state_ranking,
      :usta_sectional_ranking,
      :usta_national_ranking,
      :other_rankings,
      :playing_style,
      :individual_accomplishments,
      :ncaa_clearinghouse_id,
      :other_sports_played,
      :high_school_position,
      :high_school_coach_name,
      :high_school_coach_phone,
      :high_school_coach_email,
      :high_school_schedule,
      :high_school_team_accomplishments,
      :club_name,
      :club_position,
      :club_coach_name,
      :club_coach_phone,
      :club_coach_email,
      :club_schedule,
      :club_team_accomplishments,
      :other_teams,
      :other_teams_coach_info
  ]
  end
end
