require 'spec_helper'

describe Sport::Sales do
  describe 'class methods' do
    subject { Sport::Sales }
    its(:athletic_attributes) { should be_a Array }
    its(:statuses) { should be_a Array }
  end
end
