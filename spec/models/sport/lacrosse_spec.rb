require 'spec_helper'

describe Sport::Lacrosse do
  describe 'class methods' do
    subject { Sport::Lacrosse }
    its(:athletic_attributes) { should be_a Array }
  end
end
