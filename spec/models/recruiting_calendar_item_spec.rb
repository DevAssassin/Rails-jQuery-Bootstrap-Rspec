require 'spec_helper'

describe RecruitingCalendarItem do

  it "can be different types" do
    a = Fabricate(:recruiting_calendar_item, :message_type => :notice)
    b = Fabricate(:recruiting_calendar_item, :message_type => :alert)
    c = Fabricate(:recruiting_calendar_item, :message_type => :nada)
    a.notice?.should be_true
    b.alert?.should be_true
    c.notice?.should be_true
  end

  it "returns alerts before notices" do
    Fabricate(:recruiting_calendar_item, :message_type => :notice)
    Fabricate(:recruiting_calendar_item, :message_type => :alert)
    RecruitingCalendarItem.first.alert?.should be_true
  end

  it "returns current messages with current scope" do
    Fabricate(:recruiting_calendar_item, :start_time => 1.week.ago, :end_time => 3.days.ago)
    current_message = Fabricate(:recruiting_calendar_item, :start_time => 1.week.ago, :end_time => 3.days.from_now)
    Fabricate(:recruiting_calendar_item, :start_time => 4.days.from_now, :end_time => 1.week.from_now)
    RecruitingCalendarItem.current.all.should == [current_message]
  end

  it "returns the active calendar item for a program" do
    program = Fabricate(:program)
    item = Fabricate(:recruiting_calendar_item, :start_time => 1.week.ago, :end_time => 3.days.from_now, :program => program)

    program.current_calendar_item.should == item
  end

end
