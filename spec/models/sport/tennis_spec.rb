require 'spec_helper'

describe Sport::Tennis do
  describe 'class methods' do
    subject { Sport::Tennis }
    its(:athletic_attributes) { should be_a Array }
  end
end
