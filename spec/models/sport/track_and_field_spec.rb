require 'spec_helper'

describe Sport::TrackAndField do
  describe 'class methods' do
    subject { Sport::TrackAndField }
    its(:athletic_attributes) { should be_a Array }
  end

  it "automatically builds events" do
    recruit = Sport::TrackAndField.new

    recruit.should have(3).events
  end

end
