class Sport::Baseball < Recruit

  field :projected_position
  field :secondary_position
  field :bats
  field :throws
  field :home_to_first_time
  field :home_to_home_time
  field :batting_average
  field :at_bats
  field :strikeouts
  field :hits
  field :doubles
  field :triples
  field :home_runs
  field :rbi
  field :stolen_bases
  field :runs_scored
  field :games_started
  field :games_relieved
  field :wins
  field :losses
  field :saves
  field :ip
  field :walks
  field :era
  field :velocity
  field :twenty_eighty_scale
  field :sixty_yard_time

  # TODO refactor high school/club/other?
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
  ProjectedPositions = ["Unknown", "RHP", "LHP", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF", "DH", "IF", "OF"]
  SecondaryPositions = ["RHP", "LHP", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF", "DH", "IF", "OF"]
  BatTypes = ['Left', 'Right', 'Switch']
  ThrowTypes = ['Left', 'Right']

  def self.athletic_attributes
    [
      :projected_position,
      :secondary_position,
      :bats,
      :throws,
      :home_to_first_time,
      :home_to_home_time,
      :batting_average,
      :at_bats,
      :strikeouts,
      :hits,
      :doubles,
      :triples,
      :home_runs,
      :rbi,
      :stolen_bases,
      :runs_scored,
      :games_started,
      :games_relieved,
      :wins,
      :losses,
      :saves,
      :ip,
      :walks,
      :era,
      :velocity,
      :twenty_eighty_scale,
      :sixty_yard_time,
      :high_school_jersey_number,
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

require_dependency 'sport/softball'
