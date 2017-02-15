require 'spec_helper'

describe Sport::Gymnastics do
  describe 'class methods' do
    subject { Sport::Gymnastics }
    its(:athletic_attributes) { should be_a Array }
  end

  it "automatically builds events" do
    recruit = Sport::Gymnastics.new

    recruit.should have(3).events
  end
end
