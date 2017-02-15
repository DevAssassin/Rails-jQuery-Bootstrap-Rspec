class Interactions::EditedPhoneCall < Interaction
  field :edited_fields, :type => Hash, :default => {}
  belongs_to :phone_call, :class_name => 'Interaction'

  before_save :log_changed_fields

  TrackedFields = %w{countable status phone_number from_phone_number interaction_time duration text}

  def interaction_name
    'Edited'
  end

  def status
    'Phone Call'
  end

  def log_changed_fields
    self.edited_fields = phone_call.changes.select { |field,change| TrackedFields.include? field }
  end
end
