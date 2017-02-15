class Sport::Volleyball < Recruit

  field :jersey_number
  field :projected_position
  field :secondary_position
  field :vertical_jump
  field :approach_touch
  field :standing_reach
  field :block_touch
  field :dominant_hand

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

  ProjectedPositions = ["Outside Hitter","Middle Blocker","Right Side Hitter","Setter","Defensive Specialist","Libero"]
  SecondaryPositions = ["Unknown"] + ProjectedPositions
  DominantHandTypes = ["Right","Left"]

  def self.athletic_attributes
    [
      :jersey_number,
      :projected_position,
      :secondary_position,
      :vertical_jump,
      :approach_touch,
      :standing_reach,
      :block_touch,
      :dominant_hand,
      :individual_accomplishments,
      :ncaa_clearinghouse_id,
      :other_sports_played,
      :plays_for_high_school_team,
      :high_school_position,
      :high_school_coach_name,
      :high_school_coach_phone,
      :high_school_coach_email,
      :high_school_schedule,
      :high_school_team_accomplishments,
      :plays_for_club_team,
      :club_name,
      :club_position,
      :club_coach_name,
      :club_coach_phone,
      :club_coach_email,
      :club_schedule,
      :club_team_accomplishments,
      :plays_for_other_team,
      :other_teams,
      :other_teams_coach_info
    ]
  end

end
