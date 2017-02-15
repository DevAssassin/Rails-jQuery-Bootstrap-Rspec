class Account
  include Mongoid::Document
  add_indexes

  # fields
  field :name, :type => String
  field :allow_phonecalls, :type => Boolean
  field :allow_sms, :type => Boolean
  field :can_sms_recruits, :type => Boolean
  field :compliance, :type => Boolean
  field :rules_engine, :type => Boolean
  field :hidden_fields, :type => Array, :default => []
  field :profile_bubbles, :type => Boolean
  field :activity_at, :type => Time
  field :free, :type => Boolean, :default => false

  # mass-assignable attributes
  attr_accessible :name, :allow_phonecalls, :allow_sms,
    :can_sms_recruits, :compliance, :rules_engine, :profile_bubbles, :free

  # associations
  references_many :programs
  references_many :tasks
  references_many :forms
  references_many :completed_forms
  references_many :form_groups
  references_many :interactions
  references_many :emails
  references_many :email_templates
  #references_many :users, :stored_as => :array, :inverse_of => :accounts
  #references_and_referenced_in_many :users
  #references_many :users
  references_many :reports
  references_many :people_imports

  embeds_one :form_template

  # people relationships
  # TODO Refactor into module
  references_many :people
  references_many :recruits
  references_many :staff, :class_name => "Coach", :inverse_of => :account
  references_many :rostered_players

  alias :to_s :name

  def program_ids
    self.programs.collect(&:id)
  end

  def coaches
    staff.coaches
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

  def archives
    people.where(:_type=> "Archive")
  end

  def users
    User.where(:account_ids => self.id)
  end

  def associated_users
    User.any_of({:account_ids => self.id}, {:program_ids.in => self.program_ids})
  end

  def alert_subscribers
    # Eventually get only people who have subscribed to alerts
    # For now, return every user's email

    users.map(&:email)
  end
end
