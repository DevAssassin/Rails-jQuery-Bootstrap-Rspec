class Sport::Gymnastics < Recruit

  field :gymnastics_level
  field :years_at_level
  field :highest_level_of_competition
  field :competition_date
  field :vault_completed
  field :vault_training
  field :uneven_bars_competition_skills
  field :uneven_bars_training
  field :balance_beam_competition_skills
  field :balance_beam_training
  field :floor_exercise_competition_skills
  field :floor_exercise_training
  field :injuries

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

  Levels = %w{8 9 10 Elite Unknown}

  embeds_many :events, :class_name => "Sport::GymnasticsEvent"
  accepts_nested_attributes_for :events, :allow_destroy => true, :reject_if => :all_blank

  after_initialize :build_default_events

  def build_default_events
    3.times { events.build } if events.empty?
  end

  def self.athletic_attributes
    [
      :gymnastics_level,
      :years_at_level,
      :highest_level_of_competition,
      :competition_date,
      :vault_completed,
      :vault_training,
      :uneven_bars_competition_skills,
      :uneven_bars_training,
      :balance_beam_competition_skills,
      :balance_beam_training,
      :floor_exercise_competition_skills,
      :floor_exercise_training,
      :injuries,
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
