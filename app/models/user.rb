class User
  include Mongoid::Document
  include Canable::Cans

  add_indexes
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable


  ## Database authenticatable
  field :email,              :type => String, :null => false
  field :encrypted_password, :type => String, :null => false

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Encryptable
  # field :password_salt, :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts, :type => Integer # Only if lock strategy is :failed_attempts
  field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  field :locked_at,       :type => Time

  # Token authenticatable
  field :authentication_token, :type => String

  ## Invitable
  # field :invitation_token, :type => String



  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :token_authenticatable,
         :lockable

  field :first_name
  field :last_name
  field :title
  field :office_phone, :type => MongoTypes::PhoneNumber
  field :home_phone, :type => MongoTypes::PhoneNumber
  field :cell_phone, :type => MongoTypes::PhoneNumber
  field :twilio_callerid_sid
  field :time_zone, :default => "Eastern Time (US & Canada)"
  field :email_signature
  field :email_from
  field :superuser, :type => Boolean
  field :default_recruit_boards, :type => Hash, :default => {}
  field :editor
  field :default_only_my_contacts, :type => Boolean, :default => false
  field :default_scope
  field :plan, type: String
  field :paid, type: Boolean#, default: false

  validates_presence_of :first_name, :last_name
  validates_uniqueness_of :email, :case_sensitive => false
  attr_accessible :first_name, :last_name, :title, :office_phone,
                  :home_phone, :cell_phone, :email, :password,
                  :password_confirmation, :remember_me,
                  :account_ids, :program_ids, :time_zone, :email_signature,
                  :email_from, :default_only_my_contacts, :default_scope

  # references

  references_and_referenced_in_many :accounts, index: true
  references_and_referenced_in_many :programs, index: true
  references_many :reports
  references_many :tasks
  references_many :created_forms, :class_name => 'Form', :inverse_of => :creator
  references_many :people_imports

  #referenced_in :default_recruit_board, :class_name => "RecruitBoard"

  before_save :check_cell_phone, :add_new_account_and_programs

  attr_accessor :program, :account, :scope, :recently_invited
  attr_reader :new_account, :new_programs
  # references_many :accounts, :stored_as => :array, :inverse_of => :users
  # references_many :programs, :stored_as => :array, :inverse_of => :users

  #references_many :people, :stored_as => :array, :inverse_of => :users
  #references_many :invited_recruits, :inverse_of => :invitor, :class_name => 'Recruit'

  scope :by_last_name, order_by([:last_name, :asc])

  def self.create_and_send_invitation(invitation)
    current_scope = invitation.current_scope

    user = invitation.user || User.find_or_initialize_by({:email => invitation.recipient_email.strip.downcase})
    user.first_name ||= invitation.recipient_first_name
    user.last_name ||= invitation.recipient_last_name

    user.invite(:programs => invitation.programs, :account => invitation.account)

    return user
  end

  def self.to_csv
    csv = CSV.generate_line(['First Name','Last Name','Email','Accounts','Programs'])
    self.all.each do |u|
      csv += CSV.generate_line([u.first_name,u.last_name,u.email,u.accounts.map(&:name).join(','),u.programs.map(&:name).join(',')])
    end

    csv
  end

  def invite(options={})
    self.new_programs = options[:programs] || []
    self.new_account = options[:account] if options[:account]

    ensure_authentication_token

    if self.new_programs.size > 0 || self.new_account
      if new_record?
        UserMailer.invitation(self).deliver
      else
        UserMailer.program_added(self, self.new_programs).deliver unless self.new_programs.empty?
        UserMailer.account_added(self, self.new_account).deliver if self.new_account
      end
      self.recently_invited = true
    end

    self.reload if save(validate: false) # reload mongoid 2.1's cached associations
  end

  def recently_invited?
    self.recently_invited
  end

  # Only sets new_account if user doesn't already have access to account
  def new_account=(account)
    @new_account = self.account_ids.include?(account.id) ? nil : account
  end

  # Only sets the new programs that user doesn't already have access to
  def new_programs=(programs)
    @new_programs = programs - self.programs
  end

  def status
    case
    when self.encrypted_password.blank?
      :invited
    else
      :active
    end
  end

  def resend_invitations(account_or_program)
    if self.status == :invited
      UserMailer.invitation(self).deliver
    else
      if account_or_program.is_a?(Account)
        programs = account_or_program.programs & self.programs
        account = account_or_program if self.accounts.include?(account_or_program)
      else
        programs = self.programs.include?(account_or_program) ? [account_or_program] : []
      end
      UserMailer.program_added(self, programs).deliver unless programs.empty?
      UserMailer.account_added(self, account).deliver if account
      # Return account/programs for which invitations were delivered
      return account ? ( [account] | programs ) : programs
    end
  end

  # TODO refactor this from user and recruit
  def name
    [first_name, last_name].compact.join(" ").presence || email
  end

  alias :to_s :name

  # TODO implement this as an actual relationship when mongoid supports it
  def coached_recruits
    Recruit.where(:watcher_ids => self.id)
  end

  # TODO mongoid really should do something to this effect... at least refactor it into a module
  def update_account_ids!(acct_ids)
    self.account_ids = []
    save!

    reload

    acct_ids.map do |aid|
      begin
        Account.find(aid)
      rescue Mongoid::Errors::DocumentNotFound => e
        nil
      end
    end.compact.each do |acct|
      self.accounts << acct unless self.accounts.include?(acct)
    end

    self.reload if save!
  end

  # TODO: refactor this, it could be optimized a lot
  def update_program_ids!(prog_ids)
    self.program_ids = []
    save!

    reload

    prog_ids.map do |pid|
      begin
        Program.find(pid)
      rescue Mongoid::Errors::DocumentNotFound => e
        nil
      end
    end.compact.each do |prog|
      self.programs << prog unless self.programs.include?(prog)
    end

    reload if save!
  end

  def default_scope
    if super
      kind, id = super.split('|')
      scope = case kind
        when "Account" then find_scoped_accounts(id)
        when "Program" then find_scoped_programs(id)
      end
    end
    scope || accounts.first || programs.first
  end

  # Ideally, we'd use the following:
  #
  #     @user.programs.find(id)
  #
  # But that doesn't properly scope the result set for the #find as expected
  # So instead, we can use:
  #
  #     @user.find_scoped_programs(id)
  def find_scoped_programs(program_ids)
    if program_ids.is_a?(Array)
      program_ids = program_ids.map { |id| id.is_a?(String) ? BSON::ObjectId.from_string(id) : id }
      program_ids.keep_if { |id| self.program_ids.include? id } unless superuser?
    elsif program_ids.is_a?(String)
      program_ids = BSON::ObjectId.from_string(program_ids)
    end

    if program_ids.is_a?(Array) && !program_ids.empty?
      Program.find(program_ids)
    elsif superuser? || self.program_ids.include?(program_ids)
      Program.find(program_ids)
    else
      raise Mongoid::Errors::DocumentNotFound.new(Program, program_ids)
    end
  end

  # Ideally, we'd use the following:
  #
  #     @user.accounts.find(id)
  #
  # But that doesn't properly scope the result set for the #find as expected
  # So instead, we can use:
  #
  #     @user.find_scoped_accounts(id)
  def find_scoped_accounts(account_id)
    account_id = BSON::ObjectId(account_id) if account_id.is_a?(String)
    if superuser? || self.account_ids.include?(account_id)
      Account.find(account_id)
    else
      raise Mongoid::Errors::DocumentNotFound.new(Account, account_id)
    end
  end

  # First recruit board for current program
  def recruit_board
    default_recruit_board || program.recruit_boards.first || create_recruit_board
  end

  # All default recruit boards for current program (shown on dashboard)
  def recruit_boards
    default_recruit_boards[program.id.to_s].map { |id| program.recruit_boards.where(:_id => id).first }.compact || []
  end

  def recruit_boards=(boards)
    default_recruit_boards[program.id.to_s] = boards.map(&:id)
  end

  # User default recruit board for current program
  def default_recruit_board
    program.recruit_boards.where(:_id => recruit_boards.first.try(:id)).first
  end

  def default_recruit_board=(board)
    self.default_recruit_boards[program.id.to_s] = [board.id] + (self.default_recruit_boards[program.id.to_s] - [board.id])
  end

  # # hash of board id arrays per program
  def default_recruit_boards
    if program
      board_ids = super[program.id.to_s]
      board_ids = [board_ids] unless board_ids.is_a?(Array)
      super[program.id.to_s] = board_ids.compact
    end
    super
  end

  def show_board_on_dashboard(board)
    self.recruit_boards += [board]
  end

  def hide_board_on_dashboard(board)
    self.recruit_boards -= [board]
  end

  def email_from
    super || "Coach #{last_name}"
  end

  def full_email
    "#{email_from} <#{email}>"
  end

  def cell_phone_verified?
    !twilio_callerid_sid.blank?
  end

  def check_cell_phone
    if cell_phone_changed?
      self.twilio_callerid_sid = nil;
    end
  end

  # override this devise model method to skip current password requirement when password fields are empty
  def update_with_password(params={},email)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
      skip_current_password = true
    else
      current_password = params.delete(:current_password)
      skip_current_password = false
    end

    if skip_current_password && email != params[:email]
      current_password = params.delete(:current_password)
      skip_current_password = false
    end

    result = if skip_current_password || valid_password?(current_password)
      update_attributes(params)
    else
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      self.attributes = params
      false
    end

    clean_up_passwords
    result
  end

  def as_json *args
    intermediate_hash = super
    intermediate_hash.delete("password_salt")
    intermediate_hash.delete("encrypted_password")
    intermediate_hash
  end

  def remove_program!(program)
    self.programs.delete(program)
    self.save
  end

  def remove_account!(account)
    self.accounts.delete(account)
    self.save
  end

  def scoped_account_and_programs(current_account)
    # FIXME: WTF. when I do accounts.where(:_id => current_account.id), it throws "can't convert BSON::Id into Hash"
    # WTF would it think that :_id should be a hash?!
    account = self.accounts.where(:_id.in => [current_account.id])
    programs = self.programs.where(:account_id => current_account.id.to_s)
    account | programs
  end

  def editor
    super || 'tinymce'
  end

  def default_contact_filter
    self.default_only_my_contacts? ? self.id : ""
  end

  private

  def create_recruit_board
    rb = RecruitBoard.new(:name => "Default Recruit Board", :program => program)
    rb.save!
    self.default_recruit_board = rb
  end

  def add_new_account_and_programs
    self.programs.concat(new_programs) if self.new_programs
    self.accounts.push(new_account) if new_account
  end

end
