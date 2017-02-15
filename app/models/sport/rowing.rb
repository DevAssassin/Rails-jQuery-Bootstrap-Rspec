class Sport::Rowing < Recruit

  field :position
  field :projected_position
  field :secondary_position
  field :dominant_foot
  field :plays_for_high_school_team, :type => Boolean, :default => false
  field :high_school_jersey_number
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

  SecondaryPositions = ["Attack", "Midfield", "Defense", "Goalie"]
  ProjectedPositions = ["Unknown"] + SecondaryPositions
  Positions = ["Coxswain", "Port", "Starboard", "Scull"]
  DominantFootTypes = %w{Right Left}

  def self.athletic_attributes
    [
      :position,
      :projected_position,
      :secondary_position,
      :dominant_foot,
      :plays_for_high_school_team,
      :high_school_jersey_number,
      :high_school_position,
      :high_school_coach_name,
      :high_school_coach_phone,
      :high_school_coach_email,
      :high_school_schedule,
      :high_school_team_accomplishments,
      :plays_for_club_team,
      :club_name,
      :club_jersey_number,
      :club_position,
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
      :other_sports_played,
      :links
    ]
  end

end
