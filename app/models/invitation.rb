class Invitation
  attr_accessor :errors,
    :current_scope,
    :recipient_email, :recipient_first_name, :recipient_last_name,
    :recipient_account_level, :program_ids, :user_id, :user, :account, :programs

  def self.model_name
    @_model_name ||= ActiveModel::Name.new(self)
  end

  def initialize(current_scope, options={})
    # This is needed for when nil is actually passed in for options
    options ||= {}
    self.errors = ActiveModel::Errors.new(self)

    # Initialize attributes for user if existing user
    unless options[:user_id].blank?
      self.user = User.find(options[:user_id])
      [:email, :first_name, :last_name].each do |attr|
        self.send("recipient_#{attr}=", user.send(attr))
      end
      self.recipient_account_level = true if current_scope.is_a?(Account) && user.account_ids.include?(current_scope.id)
      self.program_ids = ( user.program_ids & (current_scope.is_a?(Account) ? current_scope.program_ids : [current_scope.id]) ).collect(&:to_s)
    end

    self.current_scope = current_scope

    # Set attributes from options
    options.each do |attr, val|
      self.send("#{attr}=", val)
    end

    self.filter_allowed_account_and_programs!
  end

  def to_key
    nil
  end

  def valid?
    blank_attr = [:recipient_first_name, :recipient_last_name, :recipient_email].find_all{ |attr| self.send(attr).blank? }
    blank_attr.each do |b|
      self.errors[b] << "can't be blank"
    end
    return !self.errors.any?
  end

  protected

  def filter_allowed_account_and_programs!
    # Filter out blank or invalid program_ids
    self.program_ids ||= []
    self.program_ids = program_ids.keep_if { |id| BSON::ObjectId.legal?(id) }

    if current_scope.is_a?(Account)
      self.account = current_scope if recipient_account_level == "1"
      self.programs = current_scope.programs.where(:_id.in => program_ids)
    else
      self.programs = [current_scope]
    end
  end
end
