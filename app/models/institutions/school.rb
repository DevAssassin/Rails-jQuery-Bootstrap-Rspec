class School < Institution
  field :nces_id
  index :nces_id
  field :subtype

  references_many :counselors, :inverse_of => :institution

  def type_name
    "High School"
  end

  def has_counselors?
    true
  end

end
