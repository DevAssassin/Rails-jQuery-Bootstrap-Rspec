require 'spec_helper'

describe Interactions::Letter do
  context "#self.export_header" do
    subject { Interactions::Letter.export_header }

    it { should be_a Array }
  end

  context "#self.export_header" do
    subject { Interactions::Letter.export_fields }

    it { should be_a Array }
  end
end
