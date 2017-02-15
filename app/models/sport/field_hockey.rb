class Sport::FieldHockey < Recruit

  field :projected_position
  field :secondary_position
  field :offensive_corner_position
  field :defensive_corner_position
  field :take_teams_strokes, :type => Boolean, :default => false
  field :on_overtime_team, :type => Boolean, :default => false
  field :stats

  # Team Fields
  field :plays_for_high_school_team, :type => Boolean, :default => false
  field :high_school_jersey_number
  field :years_on_varsity
  field :years_started_on_varsity
  field :high_school_position
  field :high_school_coach_name
  field :high_school_coach_phone, :type => MongoTypes::PhoneNumber
  field :high_school_coach_email
  field :high_school_schedule
  field :high_school_team_accomplishments
  field :plays_for_club_team, :type => Boolean, :default => false
  field :club_jersey_number
  field :club_position
  field :club_coach_name
  field :club_coach_phone, :type => MongoTypes::PhoneNumber
  field :club_coach_email
  field :club_schedule
  field :club_team_accomplishments
  field :plays_for_other_team, :type => Boolean, :default => false
  field :other_teams
  field :other_teams_coach_info

  ProjectedPositions = %w{Forward Midfield Defense Goalkeeper}
  SecondaryPositions = ["Unknown"] + ProjectedPositions
  OffensiveCornerPositions = ["Hitter","Stick Stopper","Inserter"]
  DefensiveCornerPositions = %w{Flyer Trail Post}

  def self.athletic_attributes
    [
      :projected_position,
      :secondary_position,
      :offensive_corner_position,
      :defensive_corner_position,
      :take_teams_strokes,
      :on_overtime_team,
      :stats,
      :high_school_jersey_number,
      :years_on_varsity,
      :years_started_on_varsity,
      :high_school_position,
      :high_school_coach_name,
      :high_school_coach_phone,
      :high_school_coach_email,
      :high_school_schedule,
      :high_school_team_accomplishments,
      :club_jersey_number,
      :club_name,
      :club_position,
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
