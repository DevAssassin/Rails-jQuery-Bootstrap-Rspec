class Interactions::ProfileUpdate < Interaction
  field :profile_changes, :type => Hash

  before_save :set_profile_changes

  def self.export_header
    super - ["Coach"] + ["Changed fields"]
  end

  def self.export_fields
    super - [:coach_name] + [:summary]
  end

  def interaction_name
    "Updated"
  end

  def changed_profile_fields
    self.profile_changes.try(:keys) || []
  end

  def summary
    self.changed_profile_fields.reject{ |k,v|  [ :updated_at, :sortable_name ].include?(k.to_sym) }.map(&:titleize).join(', ')
  end

  def set_profile_changes
    changes = self.person.changes.clone
    # Mongoid doesn't support persisting ActiveSupport::TimeWithZone attributes,
    # which are returned when reading changes to timestamps, so we must manually convert
    # them to UTC before persisting to the #profile_changes field
    changes.each do |key, value|
      # FIXME: Figure out why mongoid-2.3.3 is adding account_id to changed fields with no changes
      if value.nil?
        changes.delete(key)
      else
        value[0] = value[0].utc if value[0].is_a? ActiveSupport::TimeWithZone
        value[1] = value[1].utc if value[0].is_a? ActiveSupport::TimeWithZone
      end
    end
    self.profile_changes = changes
  end
end
