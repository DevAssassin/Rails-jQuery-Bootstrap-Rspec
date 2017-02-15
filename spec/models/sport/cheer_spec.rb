require 'spec_helper'

describe Sport::Cheer do
  describe 'class methods' do
    subject { Sport::Cheer }
    its(:athletic_attributes) { should be_a Array }
  end
end
