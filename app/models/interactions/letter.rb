class Interactions::Letter < Interaction
  field :subject

  def self.export_header
    super + ["Subject"]
  end

  def self.export_fields
    super + [:subject]
  end

end
