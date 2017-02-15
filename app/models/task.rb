class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  include HotDate
  add_indexes
  field :name
  field :description
  field :due_at, :type => DateTime
  field :completed_at, :type => DateTime
  field :due, :type => Boolean

  attr_accessor :skip_notify, :form_group_assignments, :new_assignments, :assignee_ids_string

  hot_datetime(:due_at)

  referenced_in :account,    index: true
  referenced_in :program,    index: true
  referenced_in :user,       index: true
  referenced_in :form,       index: true
  referenced_in :form_group, index: true
  references_many :completed_forms
  references_many :emails
  # Would be nice to have embeds_many :assignments,
  # but mongoid then won't let us directly references_many :assignments
  # from Person
  embeds_many :assignments, cascade_callbacks: true

  accepts_nested_attributes_for :assignments

  scope :completed, excludes(:completed_at => nil)
  scope :incomplete, where(:completed_at => nil)
  scope :past_due, lambda {
    where(:due_at.ne => nil, :completed_at => nil, :due_at.lt => Time.now)
  }
  scope :completed_by, lambda { |assignee_id|
    where(:'assignments.assignee_id' => assignee_id, :'assignments.completed_at'.ne => nil)
  }
  # TODO: This doesn't work, it only finds tasks for which all assignments are nil,
  # not sure why though, as the #completed_by scope above works properly
  #scope :not_completed_by, lambda { |assignee_id|
  #  where(:'assignments.assignee_id' => assignee_id, :'assignments.completed_at' => nil)
  #}
  def self.not_completed_by(assignee_id)
    scoped.find_all { |t| t.assignments.any?{ |a| a.assignee_id == assignee_id && a.completed_at.nil? } }
  end
  # TODO: Mongoid broke our sorting :-(
  #scope :sorted_by_due, order_by(:due.desc, :due_at.asc, :completed_at.asc, :created_at.asc)
  # Or this (also broken)
  #scope :sorted_by_due, desc(:due).asc(:due_at).asc(:completed_at).asc(:created_at)
  #scope :sorted_by_due, order_by([:due_at, :asc]).order_by([:completed_at, :asc]).order_by([:created_at, :asc])
  #
  # For some reason, putting it in a class-method works, but a scope doesn't
  def self.sorted_by_due
    scoped.order_by([:due, :desc]).order_by([:due_at, :asc]).order_by([:completed_at, :asc]).order_by([:created_at, :asc])
  end

  scope :account_level, where(:program_id => nil)
  scope :program_level, where(:program_id.ne => nil)
  scope :from_form_group_thread_id, lambda { |id|
    where('assignments._id' => BSON::ObjectId(id))
  }

  validates_presence_of :name, :account_id
  validate :due_at_parsed_correctly, :multiple_assignees_for_one_form_only
  validate :ensure_no_orphaned_completed_forms, if: :new_assignments

  before_validation :parse_assignee_ids_string, if: :assignee_ids_string

  before_validation :create_dependent_assignments_for_form_group, if: :form_group
  after_validation :set_assignments_from_new_assignments, if: :new_assignments_and_valid?

  before_save :set_due
  before_save :send_assignee_notifications
  before_save :ensure_assignee_tokens
  # TODO: Make this work (current implementation throws "Illegal instruction")
  #before_save :ensure_account_assignees, :if => :account_and_assignees?

  before_destroy :ensure_no_completed_forms

  def self.mass_update(tasks, action)
    perform_action = case
      when action.is_a?(Hash) && action.keys[0] == 'complete'
        [:complete!, {:person => Person.find(action.values[0])}]
      when action.is_a?(Hash) && action.keys[0] == 'delete'
        [:delete_for_assignee, Person.find(action.values[0])]
      when action == 'complete'
        [:complete!]
      when action == 'incomplete'
        [:incomplete!]
      when action == 'delete'
        [:destroy]
      end

    tasks.each{ |task| task.send(*perform_action) }
  end

  # Convenience methods
  def assignees
    self.assignments.collect(&:assignee)
  end
  def assignee_ids
    self.assignments.collect(&:assignee_id)
  end

  def assignees=(person_array)
    person_array.reject!(&:blank?)
    people_ids = person_array.inject Array.new do |array, person|
      if person.is_a?(String)
        array << BSON::ObjectId(person)
      elsif person.respond_to?(:id)
        array << person.id
      else
        array << person
      end
    end
    skipping_notification do
      self.assignments.not_in(:assignee_id => people_ids).destroy_all
      people_ids.each do |person_id|
        ass = self.assignments.find_or_initialize_by(:assignee_id => person_id)
        ass.skip_notify = true unless ass.new_record?
      end
      self.save unless self.new_record?
    end
  end

  def assignee=(person)
    self.assignees = [person]
  end

  def assignee
    self.assignees.last
  end

  def delete_for_assignee(person)
    skipping_notification do
      self.assignments.where(:assignee_id => person.id).destroy
      if self.assignments.count == 0
        self.destroy
      elsif self.assignments.where(:completed_at => nil).count == 0
        complete!
      end
    end
  end

  def complete!(options={})
    person = options[:person]
    assignment = options[:assignment]
    completed_form = options[:completed_form]

    skipping_notification do
      if person
        assignment ||= self.assignments.where(:assignee_id => person.id).first
        assignment.complete!(completed_form)
        # TODO: define exactly what :skip_notify means, since this particular notification ignores it;
        # at the moment, it just means "skip 'you have been assigned' notifications", not all notifications.
        self.send_other_assignee_completed_notifications(assignment)
        if self.assignments.where(:completed_at => nil).count == 0
          complete! # mark task complete
        else
          true # Return true from complete!(:person => assignee) action
        end
      else
        self.update_attribute(:completed_at, Time.now)
      end
    end
  end

  def incomplete!(person=nil)
    if person
      self.assignments.where(:assignee_id => person.id).first.incomplete!
    else
      self.update_attribute(:completed_at, nil)
    end
  end

  def started?
    self.assignments.any?(&:completed?)
  end

  def completed?
    self.completed_at
  end
  alias :complete? :completed?

  def completed_by?(person)
    self.assignments.where(:assignee_id => person.id).first.completed?
  end

  def past_due?
    due? && self.due_at < Time.now
  end

  def due_soon?
    due? && !past_due? && self.due_at < 2.weeks.from_now
  end

  def due?
    !completed? && self.due_at
  end

  def assignments_by_form
    self.pseudo_assignments.group_by{ |a| a.form_id }
  end

  def relavent_forms(form)
    return [] unless self.form_group
    self.form_group.form_ids.take_while{ |form_id| form_id != form.id }
  end

  def relavent_assignments(assignment)
    self.assignments.select{ |a| a.relavent_to?(assignment) }
  end

  def forms
    case
    when self.form_group
      self.form_group.forms
    when self.form
      [self.form]
    else
      []
    end
  end

  protected

  def send_assignee_notifications
    # Only notify new independent assignments or new assignments that are immediately relevant to a completed assignment
    self.assignments.select { |a| a.new? || a.recently_added? }.each do |assignment|
      if assignment.independent? || assignment.immediately_relevant_to_completed_assignment?
        unless self.skip_notify || assignment.skip_notify || assignment.assignee.email.blank?
          TaskMailer.task_assigned(assignment.assignee, assignment, self).deliver
        end
      end
    end
  end

  def send_other_assignee_completed_notifications(completed_assignment)
    if self.form_group
      send_to = self.assignments.select{ |a| completed_assignment.immediately_relevant_to?(a) }

      (send_to || []).each do |assignment|
        TaskMailer.form_group_assignment_completed(assignment.assignee, assignment, completed_assignment, self).deliver unless assignment.assignee.email.blank?
      end
    end
  end

  def ensure_assignee_tokens
    self.assignees.each do |assignee|
      if assignee.authentication_token.blank?
        assignee.ensure_authentication_token
        assignee.save
      end
    end
  end

  def ensure_account_assignees
    # Ensure only people from account can be assigned to task
    self.assignees = self.account.people & self.assignees
  end

  def account_and_assignees?
    self.account && !self.assignees.empty?
  end

  def parse_assignee_ids_string
    self.new_assignments = self.assignee_ids_string.split(',').compact.collect{ |person_id| self.assignments.find_or_initialize_by(:assignee_id => person_id) }
  end

  def set_due
    self.due = self.due_at ? 1 : 0
  end

  def due_at_parsed_correctly
    unless self.due_at.to_i > 0 || self.due_at.blank?
      errors.add(:due_at, "This due date can't be understood")
      self.due_at = ""
    end
  end

  def multiple_assignees_for_one_form_only
    if self.form_group
      if assignments_by_form.count{ |form_id, assignments| assignments.collect(&:assignee_id).uniq.size > 1 } > 1
        errors.add :form_group, "Only one form in a form group may have multiple assignees"
      end
    end
  end

  def create_dependent_assignments_for_form_group
    # if only one form exists in assignments and it has multiple assignees,
    # don't multiply any assignments
    unless singly_assigned.blank?

      # None of the forms in the group have multiple assignments (each form in the group
      # was assigned to only one person),
      # assume the first form in the group is the dependent assignment
      # Otherwise, each of the multiply-assigned form is a dependent assignment
      parent_assignments = multiply_assigned.presence || [ singly_assigned.first ]
      dependent_assignments = singly_assigned - parent_assignments

      clone_dependent_assignments(parent_assignments, dependent_assignments)
    end
  end

  def clone_dependent_assignments(parent_assignments, dependent_assignments)
    self.new_assignments = [].tap do |new_assignments|

      # For each parent assignment (multiply-assigned or first singly-assigned)
      parent_assignments.each do |parent|
        new_assignments << self.assignments.find_or_initialize_by(parent.attributes)

        # For each other singly-assigned form...
        dependent_assignments.each do |dependent|

          # create a cloned assignment for each assignee in the multiply-assigned form,
          # which is dependent upon that multiply-assigned form assignee
          new_assignments << self.assignments.find_or_initialize_by(:assignee_id => dependent.assignee_id, :form_id => dependent.form_id, :dependent_assignment_id => parent.id)
        end
      end
    end
  end

  def set_assignments_from_new_assignments
    self.assignments = self.new_assignments
  end

  def new_assignments_and_valid?
    self.new_assignments && self.errors.empty?
  end

  def pseudo_assignments
    @pseudo_assignments ||= if self.form_group_assignments
      [].tap do |assignments_array|
        self.form_group_assignments.each do |form_id, form_attr|
          form_attr[:assignee_ids_string].split(',').compact.each do |assignee_id|
            assignment = self.assignments.find_or_initialize_by(:form_id => form_id, :assignee_id => assignee_id)
            assignment.recently_added = assignment.new?
            assignments_array << assignment
          end
        end
      end
    else
      self.assignments
    end
  end

  def assignments_by_multiply_assigned
    # Can't e group_by here because it converts our array of hashes into an array of arrays
    #assignments_by_form.group_by{ |form_id, assignments| assignments.size > 1 }
    {true => [], false => []}.tap do |hash|
      assignments_by_form.each_value do |assignments|
        hash[assignments.collect(&:assignee_id).uniq.size > 1].concat assignments
      end
    end
  end

  def multiply_assigned
    assignments_by_multiply_assigned[true]
  end

  def singly_assigned
    assignments_by_multiply_assigned[false]
  end

  def skipping_notification
    s = self.skip_notify
    self.skip_notify = true
    result = yield if block_given?
    self.skip_notify = s
    return result
  end

  def ensure_no_completed_forms
    unless self.reload.completed_forms.empty?
      self.errors.add :completed_forms, "Cannot be deleted because there are already completed forms tied to this task"
      return false
    end
  end

  def ensure_no_orphaned_completed_forms
    cfs = self.completed_forms.where(:assignment_id.nin => self.new_assignments.collect(&:id)).to_a
    if cfs.any?
      cfs.group_by(&:form).each do |form, cf|
        self.errors.add :assignments, "for #{form.name} already have completed forms by #{cf.collect(&:submitter_name).join(' and ')}, and cannot be deleted"
      end
      return false
    end
  end
end
