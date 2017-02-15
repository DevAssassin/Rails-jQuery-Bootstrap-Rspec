class Sport::Football < Recruit

  field :offensive_position
  field :defensive_position
  field :special_teams_position
  field :projected_position
  field :forty_yard_time
  field :hundred_meter_time
  field :bench
  field :squat
  field :power_clean
  field :vertical_jump

  # Team Fields
  field :plays_for_high_school_team, :type => Boolean, :default => false
  field :high_school_position
  field :high_school_jersey_number
  field :high_school_coach_name
  field :high_school_coach_phone, :type => MongoTypes::PhoneNumber
  field :high_school_coach_email
  field :high_school_schedule
  field :high_school_team_accomplishments
  field :plays_for_club_team, :type => Boolean, :default => false
  field :club_position
  field :club_jersey_number
  field :club_coach_name
  field :club_coach_phone, :type => MongoTypes::PhoneNumber
  field :club_coach_email
  field :club_schedule
  field :club_team_accomplishments
  field :plays_for_other_team, :type => Boolean, :default => false
  field :other_teams
  field :other_teams_coach_info

  OffensivePositions = ["Quarterback","Tailback","Runningback","Fullback","Wide Receiver","Tight End","Offensive Tackle","Offensive Center","Offensive Guard","Athlete"]
  DefensivePositions = ["Defensive End","Defensive Tackle","Defensive Line","Nose Guard","Inside Linebacker","Outside Linebacker","Safety","Strong Safety","Free Safety","Cornerback","Defensive Back"]
  SpecialTeamsPositions = ["Kicker","Punter","Kicker/Punter","Long Snapper","Returner"]
  ProjectedPositions = ["Unknown"] + OffensivePositions + DefensivePositions + SpecialTeamsPositions - ["Returner"]

  def self.athletic_attributes
    [
      :offensive_position,
      :defensive_position,
      :special_teams_position,
      :projected_position,
      :forty_yard_time,
      :hundred_meter_time,
      :bench,
      :squat,
      :power_clean,
      :vertical_jump,
      :high_school_position,
      :high_school_jersey_number,
      :high_school_coach_name,
      :high_school_coach_phone,
      :high_school_coach_email,
      :high_school_schedule,
      :high_school_team_accomplishments,
      :club_name,
      :club_position,
      :club_jersey_number,
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
