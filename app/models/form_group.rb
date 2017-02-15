class FormGroup
  include Mongoid::Document
  include Mongoid::Timestamps
  add_indexes

  field :name
  field :description

  has_and_belongs_to_many :forms, index: true
  has_many :tasks
  has_many :completed_forms
  belongs_to :creator, :class_name => 'User', index: true
  belongs_to :account, index: true
  belongs_to :program, index: true

  mount_uploader :original, FormUploader

  scope :standalone_for, lambda { |form|
    where(:form_ids => [form.id], :account_id => form.account_id)
  }

  validates :name, presence: true
  validate :has_forms
  validate :forms_eligible_for_groups

  def self.updatable_by?(user)
    user.superuser?
  end

  def updatable_by?(user)
    self.class.updatable_by?(user) || user.accounts.include?(self.account)
  end

  def deletable?
    self.completed_forms.empty? && self.tasks.empty?
  end

  def self.destroyable_by?(user)
    user.superuser?
  end

  def destroyable_by?(user)
    self.class.destroyable_by?(user)
  end

  def forms_in_order
    self.forms.in_order(self.form_ids)
  end

  def public?
    self.forms.size == 1
  end

  def self.completed_form_counts(program = nil)
    current_scope = self.scoped

    map = "function() {
      var val = {};
      val[this.form_id] = 1;
      emit(this.form_group_id, val);
    }"

    reduce = "function(key, values) {
      var result = {};
      for (var index in values) {
        for (var k in values[index]) {
          if (!result[k]) { result[k] = 0; }
          result[k] += values[index][k];
        }
      }
      return result;
    }"

    query = current_scope.selector.merge(:form_group_id => {"$ne"=>nil})
    query.merge!(:program_id => program.id) if program

    counts = CompletedForm.collection.map_reduce(map, reduce, :query => query, :out => 'form_completed_form_counts')
    # TODO: Was trying to map these values onto the FormGroup collection, but not sure if possible
    #self.scoped.includes(:form_completed_form_counts)
    counts.find.inject( Hash.new(0) ) { |h, i| h[i.values[0]] = i.values[1]; h }
  end

  def self.pending_form_counts
    current_scope = self.scoped

    map = "function() {
      var val = {};
      for (var index in this.assignments) {
        var assignment = this.assignments[index],
            plus = assignment.completed_at ? 0 : 1;
        val[assignment.form_id] = (val[assignment.form_id] || 0) + plus;
      }
      emit(this.form_group_id, val);
    }"

    reduce = "function(key, values) {
      var result = {};
      for (var index in values) {
        for (var k in values[index]) {
          if (!result[k]) { result[k] = 0; }
          result[k] += values[index][k];
        }
      }
      return result;
    }"

    counts = Task.collection.map_reduce(map, reduce, :query => current_scope.selector.merge(:form_group_id => {"$ne"=>nil}), :out => 'form_pending_form_counts')
    counts.find.inject( Hash.new(0) ) { |h, i| h[i.values[0]] = i.values[1]; h }
  end

  def counts_from_collection(collection)
    self.form_ids.map{ |form_id|
      collection[self.id].is_a?(Hash) ? collection[self.id][form_id.to_s] : 0
    }.map(&:to_i)
  end

  protected

  def forms_eligible_for_groups
    errors.add(:forms, "Can only include forms that are eligibe to be assigned in groups") if self.forms.size > 1 && self.forms.detect{ |f| !f.eligible_for_groups }
  end

  def has_forms
    errors.add(:forms, "Must contain at least one form section") if forms.empty?
  end

end
