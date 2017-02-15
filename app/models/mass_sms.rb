class MassSms < BasicActiveModel
  attr_accessor :recipients, :text, :user

  def initialize(*args)
    super
    @recipients ||= []
  end

  def save
    # no op
    true
  end

  def send_messages(options = {})
    recipients.each do |r|
      if r.cell_phone.present?
        int = Interactions::Sms.new
        int.phone_number = r.cell_phone
        int.user = user
        int.person = r
        int.text = text
        int.execute(options) if int.save
      end
    end
  end
end
