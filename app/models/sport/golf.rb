class Sport::Golf < Recruit

  embeds_many :events, :class_name => "Sport::GolfEvent"
  accepts_nested_attributes_for :events, :allow_destroy => true, :reject_if => :all_blank

  after_initialize :build_default_events

  def build_default_events
    3.times { events.build } if events.empty?
  end

  field :usga_handicap
  field :golfweek_rank
  field :junior_golf_scoreboard_rank
  field :ajga_rank
  field :driver_distance
  field :five_iron_distance
  field :pitching_wedge_distance
  field :lowest_eighteen_hold_round
  field :home_course
  field :golf_instructor

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
      :usga_handicap,
      :golfweek_rank,
      :junior_golf_scoreboard_rank,
      :ajga_rank,
      :driver_distance,
      :five_iron_distance,
      :pitching_wedge_distance,
      :lowest_eighteen_hold_round,
      :home_course,
      :golf_instructor,
      :individual_accomplishments,
      :ncaa_clearinghouse_id,
      :other_sports_played,
      :plays_for_high_school_team,
      :high_school_coach_name,
      :high_school_coach_phone,
      :high_school_coach_email,
      :high_school_schedule,
      :high_school_team_accomplishments,
      :plays_for_club_team,
      :club_name,
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
