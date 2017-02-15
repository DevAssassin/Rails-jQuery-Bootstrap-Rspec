class Interactions::Email < Interaction
  field :subject
  field :from_email
  field :to_email
  field :token
  referenced_in :email, index: true
  has_many :events, :class_name => 'EmailEvent', :inverse_of => :interaction

  before_save :assign_token

  def self.export_header
    super + ["Subject", "From", "To", "Opened", "Clicked", "Failed"]
  end

  def self.export_fields
    super + [:subject, :from_email, :to_email, :opened_text, :clicked_text, :bounced_text]
  end

  def assign_token
    self[:token] ||= Digest::SHA1.hexdigest("--$$--#{self.id.to_s}--$$--")
  end

  def status
    if spam?
      "Marked as spam"
    elsif bounced?
      "Failed"
    elsif clicked?
      "Clicked"
    elsif opened?
      "Opened"
    end
  end

  def opened?
    events.any?(&:opened?)
  end

  def clicked?
    events.any?(&:clicked?)
  end

  def bounced?
    events.any?(&:bounced?)
  end

  def opened_text
    opened? ? 'Yes' : 'No'
  end

  def clicked_text
    clicked? ? 'Yes' : 'No'
  end

  def bounced_text
    bounced? ? 'Yes' : 'No'
  end

  def spam?
    events.any?(&:spam?)
  end

end