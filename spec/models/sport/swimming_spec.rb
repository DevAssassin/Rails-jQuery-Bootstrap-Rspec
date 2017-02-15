require 'spec_helper'

describe Sport::Swimming do
  describe 'class methods' do
    subject { Sport::Swimming }
    its(:athletic_attributes) { should be_a Array }
  end

  it "automatically builds events" do
    recruit = Sport::Swimming.new

    recruit.should have(3).events
  end
end
