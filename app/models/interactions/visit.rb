class Interactions::Visit < Interaction
  Types = ["Official", "Unofficial", "Other"]
  field :visit_type, :type => String

  validates_presence_of :visit_type, :message => "You must make a selection."

  def self.export_header
    super + ["Visit Type"]
  end

  def self.export_fields
    super + [:visit_type]
  end

end
