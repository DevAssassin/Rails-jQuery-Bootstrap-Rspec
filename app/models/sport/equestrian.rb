class Sport::Equestrian < Recruit

  field :years_riding
  field :riding_strengths
  field :riding_weaknesses
  field :hunter_seat, :type => Boolean, :default => false
  field :won_usef_medal, :type => Boolean, :default => false
  field :divisions
  field :primarily_show, :type => Boolean, :default => false
  field :catch_ride, :type => Boolean, :default => false
  field :show_hunters, :type => Boolean, :default => false
  field :what_level
  field :barn_management_skills, :type => Boolean, :default => false
  field :pull_manes, :type => Boolean, :default => false
  field :braid, :type => Boolean, :default => false
  field :western, :type => Boolean, :default => false
  field :competed_in_competition, :type => Boolean, :default => false
  field :competition_name
  field :awards
  field :reining_competition, :type => Boolean, :default => false
  field :reining_experience
  field :riding_expertise

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
      :years_riding,
      :riding_strengths,
      :riding_weaknesses,
      :hunter_seat,
      :won_usef_medal,
      :divisions,
      :primarily_show,
      :catch_ride,
      :show_hunters,
      :what_level,
      :barn_management_skills,
      :pull_manes,
      :braid,
      :western,
      :competed_in_competition,
      :competition_name,
      :awards,
      :reining_competition,
      :reining_experience,
      :riding_expertise,
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
