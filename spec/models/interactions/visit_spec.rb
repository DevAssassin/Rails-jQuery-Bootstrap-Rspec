require 'spec_helper'

describe Interactions::Visit do

  it { should validate_presence_of(:visit_type).with_message("You must make a selection.") }

  context "#self.export_header" do
    subject { Interactions::Visit.export_header }

    it { should be_a Array }
  end

  context "#self.export_header" do
    subject { Interactions::Visit.export_fields }

    it { should be_a Array }
  end


end

