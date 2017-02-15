class Interactions::Sms < Interaction
  include Rails.application.routes.url_helpers

  field :phone_number, :type => MongoTypes::PhoneNumber
  field :from, :type => MongoTypes::PhoneNumber, :default => "7346064913"
  field :status, :type => String, :default => "sent"
  field :already_sent, :type => Boolean
  field :already_logged, :type => Boolean

  validate :validate_person_smsable

  def execute(options = {})
    request = options[:request]
    unless self.already_sent
      text.scan(/.{1,140}/) do |sms_text|
        response = attempt_to_send(request, sms_text)
        self.status = twilio_status(response) if response
      end
      self.already_sent = true
    end
    update_log

    self.save!

    super
  end

  def interaction_name
    "SMS"
  end

  def callback_url(request)
    twilio_sms_callback_url(:protocol => 'https', :interaction_id => self.id.to_s, :host => request.host, :port => request.port)
  end

  def twilio_status(response)
    if tr = response["TwilioResponse"]
      if smsm = tr["SMSMessage"]
        smsm["Status"]
      elsif except = tr["RestException"]
        "Failed: #{except["Message"]}"
      end
    end
  end

  def update_log
    if 'sent' == self.status && !self.already_logged
      Stats::Sms.log(self)
      self.already_logged = true
    end
  end

  def attempt_to_send(request, sms_text)
    Twilio::Sms.message(
          self.from,
          self.phone_number,
          sms_text,
          callback_url(request)
        )
  end

  private
  def validate_person_smsable
    errors.add(:phone_number, "can't SMS this person") unless self.already_sent || user.can_sms?(person)
  end
end
