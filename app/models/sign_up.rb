class SignUp
  include Mongoid::Document
  add_indexes

  UNSUPPORTED_SPORTS = [
    'Rowing',
    [ 'Water Polo', 'WaterPolo' ],
    'Diving'
  ]
  SUPPORTED_SPORTS = [
    # e.g. 'Baseball' or ['Cross Country', 'CrossCountry']
    #                      ^ Displayed name, ^ Class name
    'Baseball',
    'Basketball',
    'Bowling',
    'Cheer',
    ['Crew (Rowing)', 'Rowing'],
    ['Cross Country', 'CrossCountry'],
    'Dance',
    'Equestrian',
    ['Field Hockey', 'FieldHockey'],
    'Football',
    'Golf',
    'Gymnastics',
    ['Ice Hockey', 'IceHockey'],
    'Lacrosse',
    ['Mountain Biking/Cyling', 'MountainBiking'],
    'Rugby',
    'Sailing',
    'Soccer',
    'Softball',
    'Swimming',
    'Tennis',
    ['Track and Field', 'TrackAndField'],
    'Volleyball',
    ['Water Polo', 'WaterPolo'],
    'Wrestling'
  ]

  ALL_SPORTS = ( SUPPORTED_SPORTS | UNSUPPORTED_SPORTS ).sort do |sport,other_sport|
    ( sport.is_a?(Array) ? sport.first : sport ).downcase <=> ( other_sport.is_a?(Array) ? other_sport.first : other_sport ).downcase
  end.push('Other')

  before_create :set_account_and_program_name,
                :set_default_paid_status

  field :first_name, type: String
  field :last_name, type: String
  field :email, type: String

  field :account_name, type: String

  field :sport_name, type: String
  field :other_sport_name, type: String
  field :program_name, type: String

  field :plan, type: String
  field :paid, type: Boolean#, default: false

  field :account_code, type: String

  referenced_in :college, index: true

  validates_inclusion_of :plan, :in => %w(single max premium basic plus),
                         :message => "%{value} is not a valid plan"
  validates_presence_of :first_name, :last_name, :email, :sport_name
  validates_with SignUpValidator

  def set_account_and_program_name
    self.account_name = self.college.try(:name)
    self.program_name = self.sport_name if self.program_name.blank?
  end

  def self.provision(email, options = {})
    sign_up = SignUp.where(:email => email).first
    if(sign_up && sign_up.sport_is_supported?)
      sign_up.account_code = options[:account_code]
      sign_up.paid = true
      sign_up.save
      sign_up.provision
    else
      SignUpMailer.unknown_account_program(email).deliver
    end
  end

  def provision
    account = Account.create!(:name => account_name, :account_code => account_code)
    program = account.programs.build(:name => program_name)
    program.sport_class_name = sport_name
    program.save
    user = User.find_or_initialize_by(email: email)
    #user.invite(account: account, program: program)
    user.invite(programs: [program])

    return account, program
  end

  def sport_is_supported?
    # If entry in SUPPORTED_SPORTS is an array, like ['Cross Country', 'CrossCountry'],
    # only check the last value, i.e. the class name. Otherwise, check the entry itself.
    SUPPORTED_SPORTS.detect { |s| ( s.is_a?(Array) ? s.last : s ) == self.sport_name }
  end

  # workaround for mongoid bug
  def college_id=(id)
    id.blank? ? super(nil) : super(id)
  end

  def send_signup_email
    SignUpMailer.signup(self).deliver
  end

  private

  def set_default_paid_status
    self.paid ||= 0
  end

end
