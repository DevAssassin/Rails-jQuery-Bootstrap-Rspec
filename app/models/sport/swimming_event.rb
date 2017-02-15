class Sport::SwimmingEvent
  include Mongoid::Document

  embedded_in :recruit

  field :kind
  field :course
  field :time

  # TODO: Delete these three fields
  field :time_min
  field :time_s
  field :time_ms

  field :date

  Kinds = ["50 Free","100 Free","200 Free","500 Free","1000 Free","1650 Free","50 Fly","100 Fly","200 Fly","50 Back","100 Back","200 Back","50 Breast","100 Breast","200 Breast","200 IM","400 IM"]
  Courses = ["Short Course Yards","Short Course Meters","Long Course Meters"]

  def time
    super || (time_min || "")+(time_s.to_i > 0 ? ":#{time_s}" : "")+(time_ms.to_i > 0 ? ".#{time_ms}" : "")
  end



end
