class Interactions::Contact < Interaction
  Types = ["Contact", "Evaluation", "Contact and Evaluation"]

  field :contact_type, :type => String
  field :others_present, :type => String
  field :location, :type => String
  field :event, :type => String

  validates_presence_of :contact_type, :message => "You must make a selection."

  def self.export_header
    super + ["Contact Type", "Others Present", "Location", "Event"]
  end

  def self.export_fields
    super + [:contact_type, :others_present, :location, :event]
  end

  def interaction_name
    name = contact_type
    name = "Contact/Eval" if name == "Contact and Evaluation"
    name
  end
end
