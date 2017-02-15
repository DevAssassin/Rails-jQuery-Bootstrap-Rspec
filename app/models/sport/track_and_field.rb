class Sport::TrackAndField < Recruit

  field :num_years_trained_competitively
  field :num_years_trained_year_round

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

  embeds_many :events, :class_name => "Sport::TrackAndFieldEvent"
  accepts_nested_attributes_for :events, :allow_destroy => true, :reject_if => :all_blank

  after_initialize :build_default_events

  def build_default_events
    3.times { events.build } if events.empty?
  end

  def self.athletic_attributes
    [
      :num_years_trained_competitively,
      :num_years_trained_year_round,
      :individual_accomplishments,
      :ncaa_clearinghouse_id,
      :other_sports_played,
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
      :other_teams_coach_info
    ]
  end
end
