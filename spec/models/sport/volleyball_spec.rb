require 'spec_helper'

describe Sport::Volleyball do
  describe 'class methods' do
    subject { Sport::Volleyball }
    its(:athletic_attributes) { should be_a Array }
  end
end
