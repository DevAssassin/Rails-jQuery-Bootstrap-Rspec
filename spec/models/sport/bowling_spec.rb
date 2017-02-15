require 'spec_helper'

describe Sport::Bowling do
  describe 'class methods' do
    subject { Sport::Bowling }
    its(:athletic_attributes) { should be_a Array }
  end
end
