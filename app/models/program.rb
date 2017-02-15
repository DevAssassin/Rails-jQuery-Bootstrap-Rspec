class Program
  include Mongoid::Document
  add_indexes

  # fields
  field :name
  field :sport_class_name
  field :thank_you_message
  field :alumni_thank_you_message
  field :notify_recruit_form, :type => Array, :default => []
  field :hidden_fields, :type => Array, :default => []

  embeds_many :custom_fields, :class_name => "Programs::CustomField"
  accepts_nested_attributes_for :custom_fields, :allow_destroy => true, :reject_if => :all_blank

  attr_accessor :notify_recruit_form_string

  # mass-assignable attributes
  attr_accessible :name, :thank_you_message, :alumni_thank_you_message, :notify_recruit_form_string, :visible_fields, :custom_fields_attributes

  before_validation :normalize_notify_recruit_form_string, :if => :notify_recruit_form_string

  # associations
  referenced_in :account, index: true
  #references_many :users, :stored_as => :array, :inverse_of => :programs
  #references_and_referenced_in_many :users
  #references_many :users
  references_many :emails
  references_many :email_templates
  references_many :interactions
  references_many :recruit_boards
  references_many :reports
  references_many :phone_call_rules
  references_many :recruiting_calendar_items

  has_many :tournaments

  # people relationships
  references_many :people
  references_many :recruits
  references_many :staff, :class_name => "Coach", :inverse_of => :program
  references_many :archives, :class_name => "Archive", :inverse_of => :program
  references_many :rostered_players
  references_many :tasks
  references_many :people_imports
  has_many :forms
  has_many :form_groups
  has_many :completed_forms

  validates :name, presence: true

  def users
    User.where(:program_ids => self.id)
  end
  # In Account, #associated_users is different, but for Program, it's the same
  alias :associated_users :users

  def coaches
    staff.coaches
  end

  def staffs
    staff.staffs
  end

  def archives
    people.where(:_type=> "Archive")
    #people.where(:_type=> "Person",:archive => true)
  end

  def donors
    people.donors
  end

  def alumni
    people.alumni
  end

  def parents
    people.parents
  end

  def others
    people.where(:_type => "Person").excludes(donor: true, parent: true, alumnus: true)
  end

  def sport_class
    "Sport::#{sport_class_name}".constantize
  end

  def thank_you_message
    super || "Thank you for updating your profile. Your information was successfully saved."
  end

  def alumni_thank_you_message
    super || "Thank you for updating your profile. Your information was successfully saved."
  end

  def current_calendar_item
    recruiting_calendar_items.current.first
  end

  def as_json(options = nil)
    extra = {}

    extra.merge!(current_calendar_item: current_calendar_item) if options && options[:rules_engine] && current_calendar_item

    super(options).merge(extra)
  end

  def visible_fields=(visible_fields)
    self.hidden_fields = sport_class.hideable_fields - visible_fields
  end

  def human_hidden_fields
    sport_class.hideable_fields.map { |f| [f, sport_class.human_attribute_name(f)] }.sort { |a,b| a.last <=> b.last }
  end

  def last_contact_update
    self.people.max(:updated_at) || "No people"
  end

  def last_interaction_update
    self.interactions.max(:updated_at) || "No interactions"
  end

  alias :to_s :name

  protected

  def normalize_notify_recruit_form_string
    self.notify_recruit_form = self.notify_recruit_form_string.split(',').map{ |s| s.strip }.reject(&:blank?)
  end
end
