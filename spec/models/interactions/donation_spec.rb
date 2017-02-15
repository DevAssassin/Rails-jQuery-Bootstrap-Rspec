require 'spec_helper'

describe Interactions::Donation do
  context "#self.export_header" do
    subject { Interactions::Donation.export_header }

    it { should be_a Array }
  end

  context "#self.export_header" do
    subject { Interactions::Donation.export_fields }

    it { should be_a Array }
  end

  context "setting amounts" do
    it "strips out dollar signs" do
      int = Fabricate(:donation_interaction)
      int.amount = "$1234.56"
      int.save

      int.reload
      int.amount.should == 1234.56
    end
  end
end
