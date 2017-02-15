class Archive < Person

  field :archive, :type => Boolean

  named_scope :archives, where(:archive => true)

  def type
    "Archive"
  end

  def self.import_fields
    super - %w{archive}
  end

end
