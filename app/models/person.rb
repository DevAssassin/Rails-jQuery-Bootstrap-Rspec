class Person
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Touch
  include Mongoid::Paranoia
  include Canable::Ables
  include Mongoid::TaggableWithContext
  include Mongoid::ScopedTags

  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper

  taggable :program_tags, :separator => ','
  taggable :account_tags, :separator => ','

  include HotDate

  add_indexes
  index :_type
  index :last_contact_time

  scope :unassigned, where(watcher_ids: [])

  # Token authenticatable
  field :authentication_token, :type => String
  devise :token_authenticatable

  before_save :ensure_authentication_token
  before_save :set_account
  before_save :set_sortable_fields
  before_save :set_searchable_fields
  after_update :deliver_invite_update_notifications, :if => :updated_by_alumnus
  after_update :add_profile_update_interaction,      :if => :updated_by_alumnus
  after_create :deliver_online_create_notifications, :if => :created_by_alumnus

  VISIBLE_ATTRIBUTES = [
    :first_name, :last_name, :nickname, :twitter_handle, :facebook_link,
    :city, :state, :home_phone, :cell_phone, :email, :birthdate, :hobbies, :family, :photo,
    :alumnus_sport, :alumnus_years_played, :alumnus_grad_year, :alumnus_post_grad_education
  ]

  SEARCH_ATTRIBUTES = [
    :first_name, :last_name, :gender, :nickname, :twitter_handle, :facebook_link, :height,
    :weight, :street, :city, :state, :country, :avg_rating,  :home_phone, :cell_phone, :email,
    :birthdate, :fathers_name, :fathers_occupation, :fathers_phone, :fathers_email, :fathers_college,
    :mothers_name, :mothers_occupation, :mothers_phone, :mothers_email, :mothers_college, :hobbies,
    :gpa, :gpa_out_of, :ip, :lives_with, :major, :student_type, :graduation_year, :wins
  ]

  # FIXME: Issue with Mongoid and inheritance assumes that we're not using objectIDs
  # in subclasses
  def self.using_object_ids?
    true
  end

  after_update :deliver_invite_update_notifications, :if => :updated_by_person
  after_update :add_profile_update_interaction,      :if => :updated_by_person

  field :first_name
  field :last_name
  field :nickname
  field :home_phone, :type => MongoTypes::PhoneNumber
  field :cell_phone, :type => MongoTypes::PhoneNumber
  field :office_phone, :type => MongoTypes::PhoneNumber
  field :email
  field :twitter_handle
  field :facebook_link
  field :birthdate, :type => Date
  hot_date :birthdate
  field :links#, :type => Array
  field :photo, :type => String
  field :family
  field :hobbies
  field :sortable_name
  field :searchable_name
  field :notes
  field :alumnus, :type => Boolean
  field :alumnus_sport
  field :alumnus_years_played
  field :alumnus_grad_year
  field :alumnus_post_grad_education
  field :parent, :type => Boolean
  field :donor, :type => Boolean
  field :donor_notes
  field :latest_donation_time, :type => DateTime
  field :latest_donation_amount, :type => BigDecimal
  field :children_ids, :type => Array, :default => []
  field :last_contact_time, :type => DateTime
  field :last_contact_info, :type => Hash

  mount_uploader :photo, PhotoUploader, :mount_on => :photo_filename

  validates_presence_of :first_name
  validates_presence_of :last_name

  # embeds
  embeds_one :address

  # TODO hate this:
  accepts_nested_attributes_for :address

  attr_accessor :created_by_alumnus, :updated_by_alumnus, :created_by_person, :updated_by_person

  # references
  referenced_in :account, :index => true
  referenced_in :program, :index => true
  references_many :completed_forms, :inverse_of => :assignee
  references_and_referenced_in_many :watchers, :class_name => "User"
  #references_and_referenced_in_many :assigned_tasks, :class_name => "Task", :inverse_of => :assignees
  referenced_in :college, :class_name => "Institution"

  # interaction relationships
  references_many :interactions
  references_many :phone_calls, :class_name => "Interactions::PhoneCall"
  references_many :donations, class_name: "Interactions::Donation"

  embeds_many :attachments, class_name: "ProfileAttachment"

  # scopes
  scope :with_name, excludes(:first_name => nil, :last_name => nil)
  scope :donors, where(:donor => true)
  scope :alumni, where(:alumnus => true)
  scope :parents, where(:parent => true)

  scope :account_level, where(:program_id => nil)
  scope :program_level, where(:program_id.ne => nil)

  def self.person_subclass(kind, program = nil)
    kind = kind.try(:singularize)

    case kind
    when 'recruit'
      program ? program.sport_class : Recruit
    when 'staff', 'coach'
      Coach
    when 'archive'
      Archive
    when 'rostered_player'
      RosteredPlayer
    else
      Person
    end
  end

  def self.smsable_by?(user)
    user.account.allow_sms?
  end

  def smsable_by?(user)
    self.class.smsable_by?(user)
  end

  def city_and_state
    [self.city.presence, self.state.presence].compact.join(', ')
  end

  def check_last_contact_time
    self.last_contact_time.to_s()
  end


  def conversion_types
    types = (Person.direct_descendants.map{|k| k.to_s} + ['Alumnus'] - ['InstitutionCoach', 'Counselor'] - [self.class.to_s]).sort
    types -= ['Recruit'] unless self.program
    types
  end

  def conversion_type=(conversion_type)
    case conversion_type
    when 'Recruit'
      self._type = self.program ? self.program.sport_class.to_s : 'Recruit'
    when 'Alumnus'
      self._type = 'Person'
      self.alumnus = true
    else
      self._type = conversion_type
    end
  end

  alias :conversion_type :_type

  def self.where_account_or_program(account_or_program)
    case account_or_program
    when Account
      where(:account_id => account_or_program.id)
    when Program
      where(:program_id => account_or_program.id)
    end
  end

  TAG_ESCAPE_REGEX = "-_!~*'()a-zA-Z\\d";

  # TODO View-related methods.  Refactor into a module/delegated wrapper.

  def self.from_auth_token(auth_token)
    # raise not_found error for auth_token access unless assigned task exists
    Person.where(:authentication_token => auth_token).first ||
      raise( Mongoid::Errors::DocumentNotFound.new(Person, nil) )
  end

  def self.token_search(query)
    query_array = query.split(' ').collect{ |q| /#{q}/i }
    if query_array.size > 1
      criteria = self.where(:first_name.in => query_array, :last_name.in => query_array)
    else
      criteria = self.any_of({:first_name.in => query_array}, {:last_name.in => query_array}, {:email.in => query_array})
    end
    return criteria
  end

  def first_name
    super.try(:strip)
  end

  def last_name
    super.try(:strip)
  end

  def display_name
    [first_name, last_name].compact.join(" ")
  end

  def street
    address.try(:street)
  end

  def city
    address.try(:city)
  end

  def state
    address.try(:state)
  end

  def country
    address.try(:country)
  end

  def post_code
    address.try(:post_code)
  end

  alias :name :display_name
  alias :to_s :display_name

  def self.export_fields
    self.fields.keys - %w{_type touched_at children_ids program_id authentication_token sortable_name searchable_name photo watcher_ids account_id club_id photo_filename college_id} + %w{watcher_names account_name program_name college_name} + address_fields
  end

  def self.human_export_fields
    export_fields.map{ |f| human_attribute_name(f) }
  end

  def self.address_fields
    %w{ street city state country post_code }
  end

  def self.import_fields
    self.export_fields - %w{_id created_at updated_at deleted_at account_id program_id alumnus parent donor watcher_ids photo_filename status program_tags_array account_tags_array college_id applied_for_admission lives_with watcher_names account_name program_name college_name} - address_fields
  end

  def self.hideable_fields
    self.fields.keys - %w{first_name last_name email student_type transfer_type transfer_release_letter graduation_year gpa projected_position school_id college_id club_id _id _type account_id program_id children_ids coach_ids watcher_ids program_tags_array account_tags_array created_at updated_at touched_at deleted_at tags authentication_token sortable_name searchable_name status photo photo_filename}
  end

  def self.find_even_if_deleted(id)
    self.deleted.where(_id: id).first || self.where(_id: id).first
  end

  def hidden_fields
    (program.try(:hidden_fields) || account.try(:hidden_fields)) & self.class.hideable_fields
  end

  def header_fields
    []
  end

  def watcher_names
    self.watchers.map {|w| w.to_s }
  end

  def account_name
    self.account.to_s
  end

  def program_name
    self.program.to_s
  end

  def college_name
    self.college.to_s
  end

  def self.csv_header
    data = human_export_fields + ["Custom Field 1", "Custom Field 2", "Custom Field 3", "Custom Field 4", "Custom Field 5", "Custom Field 6", "Custom Field 7", "Custom Field 8", "Custom Field 9"]
    CSV.generate_line(data) # human_export_fields
  end

  def to_csv(klass = nil)
    klass ||= self.class

    data = klass.export_fields.map do |attribute|
      val = self.send(attribute)
      val.kind_of?(Array) ? val.join(',') : val
    end

    #add custom fields to the export
    data += self.custom_fields.map do |f|
      val = self.custom_field(f.name).to_s
    end

    CSV.generate_line(data)
  end

  def custom_fields(section = :all)
    if section == :all
      program.custom_fields
    else
      program.custom_fields.section(section)
    end
  end

  def custom_field(field)
    self[field] || "" if custom_fields.map(&:name).include?(field)
  end

  def has_custom_fields?(section = :all)
    custom_fields(section).present?
  end

  ###
  #
  # API HELPER METHODS
  #

  def self.json_list_for_api
    all.map do |p|
      {
        id: p.id,
        first_name: p.first_name,
        last_name: p.last_name,
        school: (p.school_name if p.respond_to?(:school)),
        graduation_year: (p.graduation_year if p.respond_to?(:graduation_year)),
        image_url: p.photo.url,
        rating: (p.avg_rating if p.respond_to?(:avg_rating))
      }
    end
  end


  #
  # END API HELPER METHODS
  #
  ###


  # This allows links to deleted records.  Usually it would return nil for a deleted record, but instead we will return the id.
  def to_param
    id.to_s
  end

  def as_json(options = nil)
    super(options).reverse_merge(:sports_years_played => sports_years_played).
      merge(
        :recent_donation => recent_donation,
        :school => (school_name if self.respond_to?(:school_name)),
        :rating => (avg_rating if self.respond_to?(:avg_rating)),
        :image_url  => photo.url,
        :position => (projected_position if self.respond_to?(:projected_position)),
        :last_contact_time => (last_contact_time.in_time_zone.try(:strftime, '%b %e, %Y') if self.last_contact_time),
        :last_contact_info => last_contact_info
      )
  end

  def parents
    Person.any_in(children_ids: [self.id])
  end

  def children

    #FIXME: if id not present remove it from children_ids
    begin
      Person.find(children_ids)
    rescue
      []
    end
  end

  def children_ids
    super || []
  end

  def children_ids_string
    children_ids.join(',')
  end

  def children_ids_string=(string)
    self.children_ids = string.split(/,\s?/).keep_if { |id| BSON::ObjectId.legal?(id) }.map { |id| BSON::ObjectId.from_string(id) }
  end

  def assigned_tasks
    ::Task.where('assignments.assignee_id' => self.id)
  end

  def invite_link
    paths = Rails.application.routes.url_helpers
    host = ActionMailer::Base.default_url_options[:host]

    path = paths.invited_person_path(:auth_token => self.authentication_token)
    link_to("Click here to edit your profile", "http://#{host}#{path}")
  end

  def latest_interactions
    interactions.recent_first
  end

  def add_creation_interaction(options = {})
    defaults = {:creation_type => "Manual"}
    interaction = Interactions::Creation.new(defaults.merge(options))
    interaction.save!

    interactions << interaction
  end

  def stache_touchables
    self.attributes.merge({
      :invite_link => self.invite_link
    })
  end

  def add_deletion_interaction(options = {})
    defaults = {:deletion_type => "Manual"}
    interaction = Interactions::Deletion.new(defaults.merge(options))
    interaction.save!

    interactions << interaction
  end

  def add_restoration_interaction(options = {})
    defaults = {:restoration_type => "Manual"}
    interaction = Interactions::Restoration.new(defaults.merge(options))
    interaction.save!

    interactions << interaction
  end

  def type
    'Person'
  end

  def add_watchers(watchers)
    self.watchers = (self.watchers | watchers)
  end

  def watcher_ids=(ids)
    super(ids.delete_if { |id| id.blank? })
  end

  def sports_years_played
    [alumnus_sport, alumnus_years_played].compact.join(" : ")
  end

  def recent_donation
    time = latest_donation_time.strftime("%b %d, %Y") if latest_donation_time
    time ||= "Unknown"

    "#{number_to_currency latest_donation_amount} on #{time}" if latest_donation_amount
  end

  def transfer_student?
    student_type == 'Transfer Student'
  end

  def deliver_online_create_notifications
    self.program.notify_recruit_form.each do |email|
      mailer.online_create_notification(email, self).deliver
    end
  end

  def deliver_invite_update_notifications
    self.program.notify_recruit_form.each do |email|
      mailer.invite_update_notification(email, self).deliver
    end
  end

  def mailer
    AlumnusFormMailer
  end

  def add_profile_update_interaction
    Interactions::ProfileUpdate.create(:person => self)
  end

  def nonblank_visible_attributes
    Hash.new.tap do |h|
      Person::VISIBLE_ATTRIBUTES.each do |attr|
        h[attr] = self.send(attr)
      end
    end.reject { |k, v| v.blank? }
  end

  def thank_you_message
    self.alumnus? ? self.program.alumni_thank_you_message : self.program.thank_you_message
  end

  def contact!(interaction)
    return unless interaction.interaction_time.to_i > last_contact_time.to_i
    self.last_contact_info = {
      :interaction_id => interaction.id,
      :type => interaction.interaction_name,
      :user => interaction.user.try(:name)
    }
    self.last_contact_time = interaction.interaction_time.utc
    self.save!(:validate => false)
  end

  def set_last_contact!
    interaction = interactions.order_by(:interaction_time, :desc).first
    self.last_contact_info = {
      :interaction_id => interaction.id,
      :type => interaction.interaction_name,
      :user => interaction.user.try(:name)
    }
    self.last_contact_time = interaction.interaction_time.utc
    self.save!(:validate => false)
  end

private
  def set_account
    self.account = program.account if program
  end

  def set_sortable_fields
    self.sortable_name = [last_name,first_name].compact.join(' ').downcase
  end

  def set_searchable_fields
    self.searchable_name = [first_name,last_name].compact.join(' ').downcase
  end

end

require_dependency 'people/archive'
require_dependency 'people/coach'
require_dependency 'people/counselor'
require_dependency 'people/institution_coach'
require_dependency 'people/recruit'
require_dependency 'people/rostered_player'
