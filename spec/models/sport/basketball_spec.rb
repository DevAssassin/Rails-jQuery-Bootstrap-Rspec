require 'spec_helper'

describe Sport::Basketball do
  describe 'class methods' do
    subject { Sport::Basketball }
    its(:athletic_attributes) { should be_a Array }
  end
end
