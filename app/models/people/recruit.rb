class Recruit < Person
  extend ActiveModel::Callbacks
  include Mongoid::Paranoia

  before_save :calculate_avg_rating
  after_update :deliver_invite_update_notifications, :if => :updated_by_recruit
  after_update :add_profile_update_interaction,      :if => :updated_by_recruit
  after_create :deliver_online_create_notifications, :if => :created_by_recruit

  field :student_type, :default => "High School Student"
  field :transfer_type
  index :transfer_type
  field :transfer_release_letter, :type => Boolean, :default => false
  field :graduation_year, :type => String
  field :status, :default => 'New'
  field :gpa
  field :gpa_out_of
  field :weight
  field :height
  field :gender
  field :fathers_name
  field :fathers_occupation
  field :fathers_phone, :type => MongoTypes::PhoneNumber
  field :fathers_email
  field :mothers_name
  field :mothers_occupation
  field :mothers_phone, :type => MongoTypes::PhoneNumber
  field :mothers_email
  field :siblings
  field :friends_relatives
  field :sat_total, :type => Integer
  field :sat_verbal, :type => Integer
  field :sat_math, :type => Integer
  field :sat_writing, :type => Integer
  field :act_total, :type => Integer
  field :act_math, :type => Integer
  field :act_english, :type => Integer
  field :act_reading, :type => Integer
  field :act_science, :type => Integer
  field :class_rank
  field :class_rank_out_of
  field :counselor_info
  field :major
  field :honors_awards
  field :top_colleges
  field :ncaa_clearinghouse_id
  field :fathers_college
  field :mothers_college
  field :lives_with
  field :applied_for_admission
  field :alum
  field :hobbies
  field :school_interest
  field :financial_aid
  field :transcripts_received, :type => Boolean
  field :individual_accomplishments
  field :other_sports_played
  field :schedule
  field :high_school_coach_info
  field :avg_rating, :type => Float
  field :common_rating, :type => Float
  field :nli_received, :type => Boolean
  field :api, :type => Boolean, :default => true

  def self.smsable_by?(user)
    user.account.can_sms_recruits?
  end

  attr_accessor :created_by_recruit, :updated_by_recruit

  has_and_belongs_to_many :tournaments, :inverse_of => :people

  VISIBLE_ATTRIBUTES = [
    :first_name, :last_name, :gender, :nickname, :twitter_handle, :facebook_link,
    :height, :weight, :street, :city, :state, :post_code, :home_phone, :cell_phone, :email, :birthdate,
    :fathers_name, :fathers_occupation, :fathers_phone, :fathers_email, :fathers_college,
    :mothers_name, :mothers_occupation, :mothers_phone, :mothers_email, :mothers_college,
    :lives_with, :siblings, :friends_relatives, :hobbies, :photo,
    :school_name, :graduation_year, :gpa, :gpa_out_of,
    :sat_verbal, :sat_writing, :sat_total, :act_math, :act_english, :act_reading, :act_science, :act_total,
    :class_rank, :class_rank_out_of, :counselor_info, :major, :honors_awards, :top_colleges,
    :applied_for_admission, :alum, :school_interest, :financial_aid, :transcripts_received, :api
  ]

  # TODO implement this as an actual relationship when mongoid supports it
  def recruit_boards
    RecruitBoard.where(:recruit_ids => self.id)
  end

  # non-form fields
  field :ratings, :type => Hash

  # references
  referenced_in :school,  class_name: 'Institution', index: true
  referenced_in :club,    class_name: 'Institution', index: true

  # callbacks
  define_model_callbacks :delete
  def delete
    _run_delete_callbacks do
      super
    end
  end
  after_delete :remove_from_recruit_boards

  #delegate :city, :state, :to => :address

  StudentTypes = ["High School Student","Transfer Student"]
  TransferTypes = ["Prep","Two Year","Four Year"]

  def self.export_fields
    fields = super - ['school_id', 'ratings'] + ['club_name', 'school_name']
  end

  def self.create_from_emails(emails, program)
    # TODO: Add some graceful error handling
    emails = Recruit.parse_emails(emails)
    emails.inject [] do |ids, email|
      recruit = program.sport_class.find_or_initialize_by(:email => email, :program_id => program.id)
      recruit.save(:validate => false)
      program.recruits << recruit
      ids << recruit.id
    end
  end

  def self.parse_emails(emails)
    emails = emails.split(/[\r\n,]+/) if emails.is_a?(String)
    emails.collect(&:strip)
  end

  def self.import_fields
    super - %w{school_id club_id alumnus alumnus_sport alumnus_years_played alumnus_grad_year alumnus_post_grad_education parent donor donor_notes latest_donation_time latest_donation_amount projected_position secondary_position plays_for_high_school_team plays_for_club_team plays_for_other_team transcripts_received avg_rating common_rating}
  end

  def self.hideable_fields
    super + %w{club_name} - %w{alumnus alumnus_sport alumnus_years_played alumnus_grad_year alumnus_post_grad_education parent donor donor_notes latest_donation_time latest_donation_amount office_phone avg_rating}
  end

  def self.header_fields
    %w{projected_position height weight school college club graduation_year gpa} + super
  end

  def primary_position
    projected_position if respond_to? :projected_position
  end

  def club_name
    club.try(:name)
  end

  def school_name
    school.to_s
  end

  def school_name_high
    school.try(:name)
  end

  def latest_interactions
    interactions.recent_first
  end

  def rate(user, rating)
    self.ratings ||= {}
    self.common_rating = rating

    if rating == 0
      ratings.delete(user.id.to_s)
    else
      ratings[user.id.to_s] = rating
    end
  end

  def rating(user)
    (ratings || {})[user.id.to_s]
  end

  def rated_by?(user)
    (ratings || {})[user.id.to_s] != nil
  end

  # workaround for mongoid bug
  def school_id=(id)
    id.blank? ? super(nil) : super(id)
  end

  def school_name
    school.name if school
  end

  # TODO: refactor this, it could be optimized a lot
  def assign_board_ids(ids)
    program_boards = program.reload.recruit_boards
    new_boards = ids.delete_if(&:blank?).map{|bid| program.recruit_boards.find(bid)}

    program_boards.each do |board|
      if !new_boards.include?(board) && board.recruits.include?(self)
        board.remove_recruit(self)
        board.save
      end
    end

    add_board_ids(ids)
  end

  def add_board_ids(ids)
    new_boards = ids.delete_if(&:blank?).map{|bid| program.recruit_boards.find(bid)}

    new_boards.each do |board|
      board.push_recruit(self)
      board.save
    end
  end

  def remove_from_recruit_boards
    self.recruit_boards.each do |rb|
      rb.remove_recruit(self)
      rb.save
    end
  end

  def conversion_type=(conversion_type)
    remove_from_recruit_boards
    super(conversion_type)
  end

  def mailer
    RecruitFormMailer
  end

  def merge_recruit(recruit)
    self.interactions.push recruit.interactions
    self.watchers.push recruit.watchers
    self.add_board_ids(recruit.recruit_boards.collect {|rb| rb.id })

    self.photo = recruit.photo unless self.photo_filename?
    merged_recruit = self.attributes.delete_if{|k,v| v.blank?}.reverse_merge!(recruit.attributes)
    self.update_attributes(merged_recruit)

    self.build_address if self.address.nil?
    recruit.build_address if recruit.address.nil?
    merged_address = self.address.attributes.delete_if{|k,v| v.blank?}.reverse_merge!(recruit.address.attributes)
    self.address.update_attributes(merged_address)

    recruit.delete if self.save
  end

  def self.athletic_attributes
    [
      :individual_accomplishments,
      :ncaa_clearinghouse_id,
      :other_sports_played
    ]
  end

  def athletic_attributes
    self.class.athletic_attributes
  end

  def type
    'Recruit'
  end

  def sport_name
    self.class.to_s.sub("Sport::", "").titleize
  end

  def self.statuses
    [
      "New",
      "Take",
      "Hold",
      "Walk On",
      "Offered",
      "Accepted",
      "Rejected",
      "Committed"
    ]
  end

  def statuses
    self.class.statuses
  end
  #alias :recruit_board_ids= :assign_board_ids

  def school_class(time = Time.now)
    time = time.in_time_zone("Eastern Time (US & Canada)")

    years_until_graduation = graduation_year.to_i - time.year

    years_until_graduation -= 1 if time.mon >= 8

    case years_until_graduation
    when 0
      :senior
    when 1
      :junior
    when 2
      :sophomore
    when 3
      :freshman
    end
  end

  def as_json(options = nil)
    if options && options[:rules_engine]
      engine = RuleEngine.new do |e|
        e.interaction = Interactions::PhoneCall.new(person: self).prepare
      end

      remaining = if engine.can_interact?
        engine.calls_remaining
      else
        0
      end

      super(options).merge(calls_remaining: remaining)
    else
      super
    end
  end

  def nonblank_visible_attributes
    Hash.new.tap do |h|
      Recruit::VISIBLE_ATTRIBUTES.each do |attr|
        h[attr] = self.send(attr)
      end
    end.reject { |k, v| v.blank? }
  end

  def nonblank_athletic_attributes
    Hash.new.tap do |h|
      athletic_attributes.each do |attr|
        h[attr] = self.send(attr)
      end
    end.reject { |k, v| v.blank? }
  end

  def method_missing(name, *args)
    custom_field(name.to_s) || super
  end

  private
  def calculate_avg_rating
    vals = (ratings || {}).values
    logger = Logger.new("#{Rails.root}/log/my.log")
    logger.info vals
    rating = if vals.empty?
      0
    else
      vals.last
      #vals.inject(:+).to_f / vals.size
    end

    self.avg_rating = rating
  end
end

require_dependency 'people/counselor'
require_dependency 'people/institution_coach'
require_dependency 'sport/baseball'
require_dependency 'sport/basketball'
require_dependency 'sport/bowling'
require_dependency 'sport/cross_country'
require_dependency 'sport/equestrian'
require_dependency 'sport/field_hockey'
require_dependency 'sport/football'
require_dependency 'sport/golf'
require_dependency 'sport/gymnastics'
require_dependency 'sport/ice_hockey'
require_dependency 'sport/lacrosse'
require_dependency 'sport/sales'
require_dependency 'sport/soccer'
require_dependency 'sport/swimming'
require_dependency 'sport/tennis'
require_dependency 'sport/track_and_field'
require_dependency 'sport/volleyball'
require_dependency 'sport/wrestling'
require_dependency 'sport/mountain_biking'
require_dependency 'sport/rowing'
require_dependency 'sport/rugby'
require_dependency 'sport/sailing'
require_dependency 'sport/water_polo'
