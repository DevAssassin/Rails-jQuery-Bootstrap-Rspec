require 'spec_helper'

describe Sport::Dance do
  describe 'class methods' do
    subject { Sport::Dance }
    its(:athletic_attributes) { should be_a Array }
  end
end
