require 'spec_helper'

describe Sport::Soccer do
  describe 'class methods' do
    subject { Sport::Soccer }
    its(:athletic_attributes) { should be_a Array }
  end
end
