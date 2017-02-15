class CompletedForm
  include Mongoid::Document
  include Mongoid::Timestamps
  include Canable::Ables

  add_indexes

  referenced_in :form,       index: true
  referenced_in :form_group, index: true
  referenced_in :account,    index: true
  referenced_in :program,    index: true
  referenced_in :task,       index: true
  referenced_in :assignee, :class_name => 'Person', :inverse_of => :completed_forms, index: true
  belongs_to :reviewed_by, :class_name => 'User', index: true

  field :form_html
  field :data
  field :form_html_with_data
  field :submitter_name
  field :assignment_id
  field :reviewed, :default => false

  before_validation :set_data_from_form, :if => :form_completed?
  before_destroy :set_assignment_completed_at_to_nil, :if => :assignment_id

  validates_presence_of :form_html, :data
  validate :assignment_not_complete

  # TODO: Probably preferable to extract these methods into a CompletedFormGroup object
  def self.array_by_task(collection)
    by_task = collection.group_by(&:task_id)
    by_task.each do |task_id, completed_forms|
      by_task[task_id] = self.array_by_form_group_thread(completed_forms)
    end
  end

  def self.array_by_form_group_thread(collection)
    collection.group_by{ |cf| cf.form_group_thread_id }
  end

  def self.to_grouped(collection)
    Array.new.tap do |a|
      self.array_by_form_group_thread(collection).each do |form_group_thread_id, completed_forms|
        a << Hash.new.tap do |h|
          h[:form_group_thread_id] = form_group_thread_id
          h[:task] = completed_forms.first.task
          h[:individual_completed_forms] = completed_forms
        end
      end
    end
  end

  def self.by_form_group_thread
    self.array_by_form_group_thread(self.scoped.to_a)
  end

  def self.from_form_group_thread_id(thread_id)
    assignments = Assignment.from_form_group_thread_id(thread_id)
    self.scoped.where(:assignment_id.in => assignments.collect(&:id))
  end

  def self.destroy_all_by_thread_id(thread_id)
    self.from_form_group_thread_id(thread_id).each { |c| c.destroy }
  end

  def self.destroyable_by?(user)
    user.superuser?
  end
  def destroyable_by?(user)
    self.class.destroyable_by?(user)
  end

  def data
    ActiveSupport::JSON.decode(super)
  end

  def assignment
    self.task.assignments.detect { |a| a.id == self.assignment_id } if self.task && self.assignment_id
  end

  def form_group_thread_id
    self.assignment.dependent_assignment_id ? self.assignment.dependent_assignment_id : self.assignment.id
  end

  protected

  def set_assignment_completed_at_to_nil
    self.task.assignments.where(:_id => self.assignment_id).first.incomplete!(true)
  end

  def assignment_not_complete
    if self.task && self.assignment_id
      errors.add(:task, "has already been completed") if self.assignment.completed? && self.assignment.persisted?
    end
  end

  def form_completed?
    self.form.completed_form_data
  end

  def set_data_from_form
    self.form_html = self.form.sanitized_html
    self.data = serialize_data(self.form.completed_form_data)
    self.form_html_with_data = merge_form_html_with_data(self.data)
    self.submitter_name = ( self.form.submitter_name.blank? && self.assignee ) ? self.assignee.name : self.form.submitter_name
    if self.task && self.task.form_group
      self.form_group = self.task.form_group
    end
    self.account = form.account
    self.program = form.program
  end

  def serialize_data(hash)
    ActiveSupport::JSON.encode(hash)
  end

  def merge_form_html_with_data(the_data)
    serialized_data = CompletedForm.flat_each(the_data, "completed_form_data")

    output = Nokogiri::HTML(self.form_html)
    output = output.search('//body')

    output.search('//input').each do |input|
      if filled_in_data = serialized_data[input['name']]
        if ( input['type'] == 'checkbox' || input['type'] == 'radio' )
          if input['value'] == filled_in_data || ( filled_in_data.is_a?(Array) && filled_in_data.include?(input['value']) )
            input['checked'] = 'checked'
          end
        else
          input['value'] = filled_in_data
        end
      end
    end
    output.search('//textarea').each do |textarea|
      if filled_in_data = serialized_data[textarea['name']]
        textarea.content = filled_in_data
      end
    end
    output.search('//select').each do |select|
      if filled_in_data = serialized_data[select['name']]
        select.search("//option[@value=\"#{filled_in_data}\"]").first['selected'] = 'selected'
      end
    end

    return output.to_s
  end

  # Turns {'hi' => 'there', 'whats' => {'up' => 'with it'}, 'hey' => ['there', 'now']}
  # into {'hi' => 'there', 'whats[up]' => 'with it', 'hey[]' => ['there', 'now']}
  # for an indefinite amount of nesting, where the deepest value will always be the end value
  def self.flat_each(hash, prefix="", new_hash={})
    hash.each do |key,value|
      if value.is_a? Hash
        flat_each(value, ( "#{prefix}[#{key}]" ), new_hash)
      else
        new_hash.merge!("#{prefix}[#{key}]#{'[]' if value.is_a?(Array)}" => value)
      end
    end
    return new_hash
  end

end
