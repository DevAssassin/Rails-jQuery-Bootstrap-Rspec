class Interactions::PhoneCall < Interaction
  Statuses = ["Completed", "Left VM", "Unreachable", "Incoming", "Initiated"]

  field :phone_number, :type => MongoTypes::PhoneNumber
  field :duration, :type => Integer
  field :status, :type => String, :default => "Completed"
  field :countable, :type => Boolean, :default => true

  has_many :edits, :class_name => 'Interactions::EditedPhoneCall', :dependent => :delete

  named_scope :countable, where(countable: true)

  before_update :create_edited_interaction, :if => :changed?

  #validates_presence_of :duration

  def self.export_header
    super + ["Phone Number", "Duration", "Status"]
  end

  def self.export_fields
    super + [:phone_number, :duration, :status]
  end

  def interaction_name
    "Phone Call"
  end

  def duration=(new_duration)
    case new_duration
    when "0"
      self[:duration] = 0
    else
      self[:duration] = ChronicDuration.parse(new_duration) if new_duration
    end
  end

  def execute(options = {})
    if account.rules_engine? && person.kind_of?(Recruit)
      check_rules! + super
    else
      super
    end
  end

  def check_rules!
    engine = RuleEngine.new do |e|
      e.interaction = self
    end

    engine.interact!

    alerts = engine.alerts

    AlertMailer.send_alerts(alerts)

    alerts
  end

  def create_edited_interaction
    return unless self[:updated_by_form] && changes.keys & Interactions::EditedPhoneCall::TrackedFields
    e = Interactions::EditedPhoneCall.new({
      :person => person,
      :user => user,
      :program => program,
      :account => account,
      :phone_call => self
    })
    e.save
  end

end
