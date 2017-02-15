class Interactions::Deletion < Interaction
  field :deletion_type

  def interaction_name
    "Deleted"
  end
end
