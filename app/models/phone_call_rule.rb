class PhoneCallRule
  include Mongoid::Document
  include HotDate
  add_indexes

  attr_accessor :interaction

  field :school_class, :type => String
  field :transfer_type
  field :start_time, :type => Time
  hot_datetime :start_time
  field :end_time, :type => Time
  hot_datetime :end_time
  field :calls_allowed, :type => Integer
  field :time_period, :type => String
  field :message, :type => String

  index :school_class
  index :transfer_type
  index :start_time
  index :end_time

  referenced_in :program, index: true

  scope :for_time, ->(time) {
    time = time.in_time_zone("Eastern Time (US & Canada)")

    where(:start_time.lte => time, :end_time.gt => time)
  }

  scope :for_class, ->(klass) {
    if klass.blank?
      where(:school_class => nil)
    else
      where(:school_class => klass.to_s.capitalize)
    end
  }

  scope :for_transfer_type, ->(transfer_type) {
    where(transfer_type: transfer_type)
  }

  scope :without_transfer_type, where(transfer_type: nil)

  def can_interact?
    raise ArgumentError.new("You must specify a person and time!") unless (person && time)

    time_ok? && calls_allowed_ok? && transfer_status_ok?
  end

  def time_ok?
    (time >= start_time) && (time < end_time)
  end

  def calls_allowed_ok?
    calls_allowed > calls_this_period || unlimited?
  end

  def transfer_status_ok?
    if person.transfer_student? && person.transfer_type == 'Four Year'
      person.transfer_release_letter
    else
      true
    end
  end

  def calls_this_period
    person.phone_calls.
      countable.
      between_times(period_date_range).
      where(:_id.ne => interaction.id).
      count
  end

  def calls_remaining
    if unlimited?
      -1
    else
      remain = calls_allowed - calls_this_period

      [remain, 0].max
    end
  end

  def unlimited?
    calls_allowed == -1
  end

  def period_date_range
    time = self.time.in_time_zone("Eastern Time (US & Canada)")

    max_range = case time_period
    when 'day'
      time.beginning_of_day..time.tomorrow.beginning_of_day
    when 'week'
      beginning = time.beginning_of_week.yesterday
      beginning..beginning.advance(:weeks => 1)
    when 'month'
      beginning = time.beginning_of_month
      beginning..beginning.advance(:months => 1)
    else #period or none selected
      start_time..end_time
    end

    ([max_range.begin, start_time].max)..([max_range.end, end_time].min)
  end

  def time
    interaction.interaction_time
  end

  def person
    interaction.person
  end

  def school_class=(klass)
    klass = nil if klass.blank?
    super(klass)
  end

  def transfer_type=(type)
    type = nil if type.blank?
    super(type)
  end

end
