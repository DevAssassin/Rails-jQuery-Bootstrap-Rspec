require 'spec_helper'

describe Sport::Golf do
  describe 'class methods' do
    subject { Sport::Golf }
    its(:athletic_attributes) { should be_a Array }
  end

  it "automatically builds events" do
    recruit = Sport::Golf.new

    recruit.should have(3).events
  end
end
