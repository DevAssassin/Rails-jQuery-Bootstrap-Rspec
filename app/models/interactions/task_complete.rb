class Interactions::TaskComplete < Interaction
  field :assignment_id
  field :task_name
  field :due_at, :type => DateTime

  referenced_in :task
  referenced_in :completed_form

  before_save :set_due_at

  def self.export_header
    super - ["Coach", "Notes"]
  end

  def self.export_fields
    super - [:coach_name, :text]
  end

  def interaction_name
    "Completed"
  end

  protected
  def set_due_at
    self.due_at = self.due_at.utc if self.due_at.is_a? ActiveSupport::TimeWithZone
  end

  private
  # Override methods from base Interaction class to set program and
  # account from task instead of person
  def set_program
    self.program = task.program if task
  end

  def set_account
    self.account = task.account if task
  end
end
