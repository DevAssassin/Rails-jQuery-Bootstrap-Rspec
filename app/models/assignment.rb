class Assignment
  include Mongoid::Document
  add_indexes
  field :completed_at
  field :dependent_assignment_id

  embedded_in :task
  referenced_in :assignee, :class_name => 'Person'
  referenced_in :form
  referenced_in :completed_form

  attr_accessor :skip_notify, :recently_completed, :recently_added

  after_create :add_task_assigned_interaction

  def self.from_form_group_thread_id(id)
    task = Task.from_form_group_thread_id(id).first
    bson_id = BSON::ObjectId(id)
    task.assignments.select { |a| a.id == bson_id || a.dependent_assignment_id == bson_id }
  end

  def completed?
    self.completed_at
  end
  alias :complete? :completed?

  def incomplete?
    !completed?
  end

  def complete!(completed_form=nil)
    self.recently_completed = !self.completed?
    self.update_attributes(:completed_at => Time.now, :completed_form => completed_form)
    Interactions::TaskComplete.create(
      :person => self.assignee,
      :assignment_id => self.id,
      :task_id => self.task.id, # Really weird bug, if :task => self.task, shit breaks, but :task_id => task.id seems to work, no idea why
      :task_name => self.task.name,
      :text => self.task.description,
      :due_at => self.task.due_at,
      :completed_form => self.completed_form
    )
  end

  def incomplete!(delete_completed_form=false)
    self.completed_at = nil
    self.completed_form_id = nil if delete_completed_form
    self.save
    self.task.incomplete! # mark task incomplete
  end

  alias_method :assignee_without_deleted, :assignee
  def assignee
    self.assignee_without_deleted || Person.deleted.find(assignee_id)
  end

  # We can't do a referenced assignment because it's embedded in task
  # so this will be our workaround
  def dependent_assignment
    self.task.assignments.find(self.dependent_assignment_id)
  end

  def independent?
    !form || dependent_assignment_id.blank?
  end

  # This assignment has to be completed before other_assignment can be completed
  def relavent_to?(other_assignment)
    forms = self.task.relavent_forms(other_assignment.form)
    forms.include?(self.form_id) && (
      ( self.id == other_assignment.dependent_assignment_id ) ||
      ( self.task.singly_assigned.include?(self) && self.dependent_assignment_id == other_assignment.dependent_assignment_id )
    )
  end

  # This assignment comes immediately before other_assignment
  def immediately_relevant_to?(other_assignment)
    order = self.task.form_group.form_ids
    relavent_to?(other_assignment) && order.index(other_assignment.form_id) == order.index(self.form_id) + 1
  end

  def immediately_relevant_to_completed_assignment?
    self.task.assignments.select(&:completed?).any? { |other_assignment| relavent_to?(other_assignment) }
  end

  def recently_added?
    recently_added == true
  end

  protected

  def add_task_assigned_interaction
    Interactions::TaskAssign.create(
      :person => self.assignee,
      :assignment_id => self.id,
      :task_id => self.task.id,
      :task_name => self.task.name,
      :text => self.task.description,
      :due_at => self.task.due_at,
      :user => self.task.user
    )
  end

end
