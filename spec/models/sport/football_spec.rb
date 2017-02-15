require 'spec_helper'

describe Sport::Football do
  describe 'class methods' do
    subject { Sport::Football }
    its(:athletic_attributes) { should be_a Array }
  end
end
