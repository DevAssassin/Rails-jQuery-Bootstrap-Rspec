class Interactions::Alert < Interaction
  field :violation, type: Boolean
  field :reviewed_at, type: Time
  field :subject, type: String
  field :details, type: String

  referenced_in :reviewed_by, class_name: "User",        index: true
  referenced_in :caused_by,   class_name: "Interaction", index: true

  scope :visible, where(:reviewed_at => nil)

  def reviewed_by_name
    reviewed_by.try(:name)
  end

  def self.export_header
    super + ["Violation", "Reviewed At", "Reviewed By", "Subject", "Details"]
  end

  def self.export_fields
    super + [:violation, :reviewed_at, :reviewed_by_name, :subject, :details]
  end
end
