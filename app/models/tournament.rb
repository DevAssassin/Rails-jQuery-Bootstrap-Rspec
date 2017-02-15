class Tournament
  include Mongoid::Document
  include Mongoid::Timestamps
  include HotDate
  add_indexes

  scope :past, where(:end_date => { '$lt' => Date.today})
  scope :current, where(:end_date => { '$gte' => Date.today})

  field :name
  field :city
  field :state
  field :country
  field :begin_date, :type => Time
  field :end_date, :type => Time
  field :comment

  hot_datetime :begin_date
  hot_datetime :end_date

  belongs_to :program
  has_and_belongs_to_many :people, :class_name => 'Recruit', :inverse_of => :tournaments

  validates_presence_of :name
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :country
  validates_presence_of :begin_date
  validates_presence_of :end_date

  def country
    super || Country.list_for_select.first
  end

end
