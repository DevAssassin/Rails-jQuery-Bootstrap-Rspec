class Sport::Rugby < Recruit

  field :position
  field :dominant_hand
  field :points_per_game
  field :field_goal_percentage
  field :three_point_percentage
  field :free_throw_percentage
  field :rebounds_per_game
  field :assists_per_game
  field :steals_per_game
  field :vertical_jump

  # Team Fields
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

  Positions = ["Loosehead Prop", "Hooker", " Tighthead Prop", "Lock", "Flanker", "Eightman", "Scrumhalf", "Flyhalf", "Inside Center", "Outside Center", "Wing", "Fullback"]
  DominantHandTypes = ["Right","Left"]

  def self.athletic_attributes
    [
      :position,
      :dominant_hand,
      :points_per_game,
      :field_goal_percentage,
      :three_point_percentage,
      :free_throw_percentage,
      :rebounds_per_game,
      :assists_per_game,
      :steals_per_game,
      :vertical_jump,
  		:high_school_jersey_number,
  		:high_school_position,
  		:high_school_coach_name,
  		:high_school_coach_phone,
  		:high_school_coach_email,
  		:high_school_schedule,
  		:high_school_team_accomplishments,
      :club_name,
  		:club_jersey_number,
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
