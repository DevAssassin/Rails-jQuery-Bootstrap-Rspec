require 'spec_helper'

describe Sport::SwimmingEvent do
  context 'the event has the old time format' do
    before do
      subject.time = nil
      subject.time_min = '2'
      subject.time_s = '45'
      subject.time_ms = '23'
    end

    its(:time) { should == '2:45.23' }
  end
end
