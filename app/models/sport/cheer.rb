class Sport::Cheer < Recruit

  field :years_on_varsity
  field :years_gymnastics
  field :years_cheerleading
  field :stunt_positions
  field :standing_tumbling
  field :running
  field :stunting
  field :tumbling
  field :cradles

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

  def self.athletic_attributes
    [
      :years_on_varsity,
  		:years_gymnastics,
  		:years_cheerleading,
  		:stunt_positions,
  		:standing_tumbling,
  		:running,
  		:stunting,
  		:tumbling,
  		:cradles,
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
