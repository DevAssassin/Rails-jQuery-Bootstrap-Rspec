class Form
  include Mongoid::Document
  include Mongoid::Timestamps
  add_indexes

  field :name
  field :description
  field :html
  field :sanitized_html
  field :eligible_for_groups, :type => Boolean, :default => true
  field :eligible_for_standalone, :type => Boolean, :default => true

  references_many :tasks
  references_many :completed_forms
  referenced_in :creator, :class_name => 'User', :inverse_of => :created_forms, index: true
  referenced_in :account, index: true

  references_and_referenced_in_many :form_groups, index: true

  attr_accessor :completed_form_data, :task, :assignee, :submitter_name, :assignment, :program

  before_validation :sanitize_html
  after_save :create_form_group_for_eligible

  validates_presence_of :name, :html
  validate :eligible_for_groups_or_standalone

  # Weird bug, with `:eligible_for_groups => true`, not all forms with true actually get returned
  scope :eligible_for_groups, where(:eligible_for_groups.ne => false)

  def self.in_order(id_array)
    self.scoped.to_a.sort_by{ |form| id_array.index(form.id) }
  end

  def submit!
    task_complete_options = {}
    completed_form = self.completed_forms.build
    if self.task
      completed_form.task = self.task
      if self.assignee
        completed_form.assignee = self.assignee
        task_complete_options[:person] = self.assignee
        if self.assignment
          completed_form.assignment_id = self.assignment.id
          task_complete_options[:assignment] = self.assignment
        end
        task_complete_options[:completed_form] = completed_form
      end
    end
    completed_form.save!
    self.task.complete!(task_complete_options) if self.task
  end

  def pending_forms
    self.tasks.incomplete
  end

  def set_assignee_and_task(auth_token, task_id=nil, assignment_id=nil)
    self.assignee = Person.from_auth_token(auth_token)
    if task_id
      task_id = BSON::ObjectId(task_id) if task_id.is_a?(String)
      task_selector = Task.where(:_id => task_id, :form_id.in => [self.id, nil])
    else
      task_selector = Task.any_in(:_id => self.tasks.collect(&:id))
    end
    self.task = task_selector.where('assignments.assignee_id' => self.assignee.id).first
    raise Mongoid::Errors::DocumentNotFound.new(Task, task_id) unless self.task
    self.assignment = self.task.assignments.select { |a| a.assignee_id == self.assignee.id && [self.id, nil].include?(a.form_id) }
    if assignment_id
      assignment_id = BSON::ObjectId(assignment_id) if assignment_id.is_a?(String)
      self.assignment = self.assignment.detect{ |a| a.id == assignment_id }
    else
      self.assignment = self.assignment.first
    end
    raise Mongoid::Errors::DocumentNotFound.new(Assignment, assignment_id) unless self.assignment
  end

  def deletable?
    self.completed_forms.empty? && self.tasks.empty?
  end

  def relavent_forms
    self.task.relavent_forms(self)
  end

  def relavent_assignments
    self.task.relavent_assignments(self.assignment)
  end

  def standalone_and_grouped?
    self.eligible_for_standalone && self.eligible_for_groups
  end

  def standalone?
    FormGroup.standalone_for(self).exists?
  end

  protected

  def sanitize_html
    fragment = Nokogiri::HTML(self.html) do |config|
      config.noblanks.noent.strict
    end
    # strip out form tags (aka unwrap, if that method existed in Nokogiri)
    if forms = fragment.search('//form')
      forms.each do |f|
        f.children.each do |child|
          f.parent << child
        end
      end
    forms.remove
    end

    fragment.search('//input[@type="submit"]', '//input[@type="file"]').remove
    inputs = fragment.search('//input','//textarea','//select')
    labels = fragment.search('//label')

    inputs.each do |input|
      return errors.add(:html, "Field missing `name' attribute: &lt;#{input.name}&gt; with id=\"#{input.attribute('id')}\" class=\"#{input.attribute('class')}\"") unless name = input.attribute('name').try(:value)
      base_name, rest_name = split_input_name(name)
      input.attribute('name').value = "completed_form_data[#{base_name}]#{rest_name}"
    end
    labels.each do |label|
      if name = label.attribute('for').try(:value)
        base_name, rest_name = split_input_name(name)
        label.attribute('for').value = "completed_form_data[#{base_name}]#{rest_name}"
      end
    end

    self.sanitized_html = fragment.to_s
  end

  def split_input_name(name)
    # splits 'hi[there][whats][up]' into ["", "hi", "[there][whats][up]"]
    name = name.split(/([^\[]+)(.*)/)
    return name[1], name[2]
  end

  def create_form_group_for_eligible
    if self.eligible_for_standalone && !FormGroup.standalone_for(self).exists?
      FormGroup.create(:account_id => self.account_id, :name => self.name, :description => self.description, :form_ids => [self.id])
    end
  end

  def eligible_for_groups_or_standalone
    errors.add(:eligible_for_standalone, "Form must be allowed to be assigned either in groups or standalone") unless self.eligible_for_groups || self.eligible_for_standalone
  end

end
