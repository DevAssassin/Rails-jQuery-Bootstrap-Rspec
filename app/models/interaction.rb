class Interaction
  include Mongoid::Document
  include Mongoid::Timestamps
  add_indexes
  index :_type

  after_initialize :set_interaction_time
  before_validation :set_program, :set_account

  after_save :update_person_last_contact

  field :text
  field :interaction_time, :type => Time

  referenced_in :person
  referenced_in :user
  referenced_in :program
  referenced_in :account

  scope :recent_first, desc(:interaction_time, :created_at)
  scope :account_level, where(:program_id => nil)
  scope :program_level, where(:program_id.ne => nil)
  scope :between_times, ->(range) {
    #where(:interaction_time.gte => start_time, :interaction_time.lt => end_time)
    where(:interaction_time.gte => range.begin, :interaction_time.lt => range.end)
  }

  CONTACT_TYPES = %w(PhoneCall Email Visit Sms Contact)

  def self.find_subclass(type)
    type.blank? ? Interaction : Interactions.const_get(type.to_sym)
  end

  def self.where_account_or_program(account_or_program)
    case account_or_program
    when Account
      where(:account_id => account_or_program.id)
    when Program
      where(:program_id => account_or_program.id)
    end
  end

  def self.export_header
    ["Name", "Coach", "Time", "Notes"]
  end

  def self.export_fields
    [:person_name, :coach_name, :interaction_time, :text]
  end

  alias_method :parent_person, :person
  def person
    self.parent_person || Person.deleted.where(_id: self.person_id).first
  end

  # Returns the class name inside the interactions module
  def interaction_type
    self.class.name.demodulize
  end

  # Returns the display name for this kind of interaction
  def interaction_name
    interaction_type
  end

  def person_name
    person.try(:name) || 'Unknown'
  end

  def coach_name
    user.try(:name) || 'Unknown'
  end

  def execute(options = {})
    [self]
  end

  def prepare
    set_program
    set_account

    self
  end

  def serializable_hash(options = nil)
    options ||= {}
    methods = options[:methods] || []
    methods |= [:_type]

    super(options.merge(:methods => methods))
  end

  private
  def set_interaction_time
    self.interaction_time = Time.now unless self.interaction_time
  end

  def set_program
    self.program = person.program if person && person.program
  end

  def set_account
    self.account = person.account if person && person.account
  end
  def update_person_last_contact
    person.contact!(self) if CONTACT_TYPES.include? self.class.name.split('::').last
  end
end

require_dependency 'interactions/comment'
require_dependency 'interactions/contact'
require_dependency 'interactions/creation'
require_dependency 'interactions/deletion'
require_dependency 'interactions/donation'
require_dependency 'interactions/email'
require_dependency 'interactions/letter'
require_dependency 'interactions/phone_call'
require_dependency 'interactions/rating'
require_dependency 'interactions/restoration'
require_dependency 'interactions/sms'
require_dependency 'interactions/visit'
require_dependency 'interactions/profile_update'
require_dependency 'interactions/task_assign'
require_dependency 'interactions/task_complete'
