require 'spec_helper'

describe Sport::Baseball do
  describe 'class methods' do
    subject { Sport::Baseball }
    its(:athletic_attributes) { should be_a Array }
  end
end
