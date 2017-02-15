class Interactions::Creation < Interaction
  field :creation_type

  delegate :street,
           :city,
           :state,
           :post_code,
           :country,
           :home_phone,
           :cell_phone,
           :email,
           :program_tags,
           :account_tags,
           to: :person, prefix: true, allow_nil: true

  delegate :graduation_year,
           :sport_name,
           :major,
           :gpa,
           :applied_for_admission,
           :gender,
           :height,
           :weight,
           :school_name_high,
           :club_name,
           :primary_position,
           to: :recruit, prefix: true, allow_nil: true

  def interaction_name
    'Created'
  end

  def self.export_header
    [
      'Name',
      'Home Phone',
      'Cell Phone',
      'Email',
      'Gender',
      'GPA',
      'Height',
      'Weight',
      'High school name',
      'Club name',
      'Primary position',
      'Street',
      'City',
      'State',
      'Zip',
      'Country',
      'Source'
    ]
  end

  def self.export_fields
    [
      :person_name,
      :person_home_phone,
      :person_cell_phone,
      :person_email,
      :recruit_gender,
      :recruit_gpa,
      :recruit_height,
      :recruit_weight,
      :recruit_school_name_high,
      :recruit_club_name,
      :recruit_primary_position,
      :person_street,
      :person_city,
      :person_state,
      :person_post_code,
      :person_country,
      :person_source
    ]
  end

  def person_source
    if person_account_tags.include?('Import')
      'Import'
    else
      'Manual'
    end
  end

  def recruit
    self.person if self.person.is_a?(Recruit)
  end
end
