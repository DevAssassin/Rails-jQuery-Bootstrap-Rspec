class Sport::MountainBiking < Recruit

  field :type_of_rider
  field :cross_country, :type => Boolean, :default => false
  field :short_track, :type => Boolean, :default => false
  field :dual_slalom, :type => Boolean, :default => false
  field :downhill, :type => Boolean, :default => false
  field :ultra_endurance, :type => Boolean, :default => false
  field :road_racing, :type => Boolean, :default => false
  field :criterium, :type => Boolean, :default => false
  field :time_trial, :type => Boolean, :default => false
  field :cyclocross, :type => Boolean, :default => false
  field :cross_country1, :type => Boolean, :default => false
  field :short_track1, :type => Boolean, :default => false
  field :dual_slalom1, :type => Boolean, :default => false
  field :downhill1, :type => Boolean, :default => false
  field :ultra_endurance1, :type => Boolean, :default => false
  field :road_racing1, :type => Boolean, :default => false
  field :criterium1, :type => Boolean, :default => false
  field :time_trial1, :type => Boolean, :default => false
  field :cyclocross1, :type => Boolean, :default => false
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
  TypeOfRider = ["Track", "Mountain Endurance", "Mountain Gravity", "Road", "BMX", "All Arounder"]
  EventOptions = ["Cross Country", "Short Track", "Dual Slalom", "Downhill", "Ultra Endurance (50 Miles Plus)", "Road Racing", "Criterium", "Time Trial", "Cyclocross"]
  DominantFootTypes = %w{Right Left}

  def self.athletic_attributes
    [
      :type_of_rider,
      :cross_country,
      :short_track,
      :dual_slalom,
      :downhill,
      :ultra_endurance,
      :road_racing,
      :criterium,
      :time_trial,
      :cyclocross,
      :cross_country1,
      :short_track1,
      :dual_slalom1,
      :downhill1,
      :ultra_endurance1,
      :road_racing1,
      :criterium1,
      :time_trial1,
      :cyclocross1,
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
