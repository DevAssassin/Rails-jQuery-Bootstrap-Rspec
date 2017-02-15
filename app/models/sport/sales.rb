class Sport::Sales < Recruit

  field :sport_name
  field :conference
  field :division
  field :title
  field :referral
  field :first_contact

  def self.statuses
    ["Cold Lead", "Contacted", "Warm Lead", "With Competitor", "Not Interested", "Demoed", "Trial", "Customer"]
  end

  def self.athletic_attributes
    [
      :sport_name,
      :conference,
      :division,
      :title,
      :referral,
      :first_contact,
      :links
    ]
  end
end
