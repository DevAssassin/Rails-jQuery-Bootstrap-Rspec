require 'spec_helper'

describe Sport::FieldHockey do
  describe 'class methods' do
    subject { Sport::FieldHockey }
    its(:athletic_attributes) { should be_a Array }
  end
end
