class RecruitingCalendarItem
  include Mongoid::Document
  add_indexes

  field :start_time, :type => Time
  field :end_time, :type => Time
  field :message, :type => String
  field :message_type, :type => String, :default => "notice"

  MessageTypes = {
    "Notice (Blue)" => "notice",
    "Alert (Red)" => "alert"
  }

  default_scope order_by([:message_type,:asc])
  scope :current, -> { where(:start_time.lte => Time.now, :end_time.gt => Time.now) }

  referenced_in :program, index: true

  def alert?
    message_type == "alert"
  end

  def notice?
    message_type != "alert"
  end

end
