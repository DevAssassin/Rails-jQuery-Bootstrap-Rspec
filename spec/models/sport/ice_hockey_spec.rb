require 'spec_helper'

describe Sport::IceHockey do
  describe 'class methods' do
    subject { Sport::IceHockey }
    its(:athletic_attributes) { should be_a Array }
  end
end
