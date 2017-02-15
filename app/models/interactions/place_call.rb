class Interactions::PlaceCall < Interactions::PhoneCall
  include Rails.application.routes.url_helpers

  DefaultCallerId = '734-606-4913'

  field :from_phone_number, :type => MongoTypes::PhoneNumber
  field :placed, :type => Boolean
  attr_accessor :force

  validate :no_rules_violations

  before_create lambda { |rec| rec.status = "Initiated"; rec.countable = false; true }

  def no_rules_violations
    if !force && new_record?
      engine = RuleEngine.new do |e|
        e.interaction = self
      end

      errors.add(:phone_number, 'No more calls are allowed to this recruit at this time.') unless engine.can_interact?
    end
  end

  def caller_id
    user.cell_phone_verified? ? user.cell_phone : DefaultCallerId
  end

  def execute(options = {})
    request = options[:request]

    if !placed
      Twilio::Call.make(
        DefaultCallerId,
        from_phone_number,
        twilio_connect_url(:protocol => 'https', :interaction_id => self.id.to_s, :host => request.host, :port => request.port),
        :StatusCallback => twilio_complete_url(:protocol => 'https', :interaction_id => self.id.to_s, :host => request.host, :port => request.port)
      )

      update_attribute(:placed, true)
    end

    super
  end
end
