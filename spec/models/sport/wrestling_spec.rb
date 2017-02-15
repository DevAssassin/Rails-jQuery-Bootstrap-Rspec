require 'spec_helper'

describe Sport::Wrestling do
  describe 'class methods' do
    subject { Sport::Wrestling }
    its(:athletic_attributes) { should be_a Array }
  end
end
