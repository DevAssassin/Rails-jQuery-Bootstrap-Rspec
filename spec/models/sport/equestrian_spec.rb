require 'spec_helper'

describe Sport::Equestrian do
  describe 'class methods' do
    subject { Sport::Equestrian }
    its(:athletic_attributes) { should be_a Array }
  end
end
