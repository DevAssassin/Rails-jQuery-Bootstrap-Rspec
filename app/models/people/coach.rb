class Coach < Person

  #referenced_in :coached_program, :class_name => "Program"

  field :office_phone, :type => MongoTypes::PhoneNumber
  field :family
  field :hobbies
  field :sport
  field :job_title
  field :job_description
  field :department
  field :reports_to
  field :coach, :type => Boolean

  named_scope :coaches, where(:coach => true)
  named_scope :staffs, where(:coach => false)

  def type
    "Coach"
  end

  def self.import_fields
    super - %w{coach}
  end

end
