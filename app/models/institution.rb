class Institution
  include Mongoid::Document
  add_indexes
  index :_type
  field :name, :type => String
  field :phone_number, :type => MongoTypes::PhoneNumber
  field :website

  # FIXME: Issue with Mongoid and inheritance assumes that we're not using objectIDs
  # in subclasses
  def self.using_object_ids?
    true
  end

  # embeds
  embeds_one :address
  accepts_nested_attributes_for :address

  # references
  references_many :recruits, :inverse_of => :school
  references_many :coaches, :class_name => "InstitutionCoach"

  references_and_referenced_in_many :users, index: true

  # delegates
  delegate :street, :city, :state, :country, :post_code, to: :address, allow_nil: true

  def recruits_for_program(program)
    Person.where(:program_id => program.id).
      any_of(
        { :school_id => self.id },
        { :college_id => self.id },
        { :club_id => self.id }
    )
  end

  def self.search(string)
    regex = '\b' << Regexp.escape(string)

    self.where(:name => Regexp.new(regex, true))
  end

  def display_name
    name.try(:titleize) || ""
  end

  alias :to_s :display_name

  def type_name
    self.class.to_s
  end

  def has_counselors?
    false
  end

  def set_coach_ids_for_program( new_coach_ids, program )
    old_coach_ids = (self.user_ids || []).map(&:to_s)
    program_coaches = program.users.map {|u| u.id.to_s}
    good_new_coaches = program_coaches & new_coach_ids.map(&:to_s)
    new_coaches = old_coach_ids - program_coaches + good_new_coaches
    self.user_ids = new_coaches
    save
  end
end

require_dependency 'institutions/school'
require_dependency 'institutions/college'
require_dependency 'institutions/club'
