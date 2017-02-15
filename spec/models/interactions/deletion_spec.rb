require 'spec_helper'

describe Interactions::Deletion do
  its(:interaction_name) { should be_a String }
end
