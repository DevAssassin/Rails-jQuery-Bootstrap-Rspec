require 'spec_helper'

describe Interactions::ProfileUpdate do
  before :each do
    @recruit = Fabricate(:recruit)
    @recruit.update_attributes(:updated_by_recruit => true, :first_name => "Steve", :last_name => "McDudersauce")
    @interaction = Interaction.last
  end

  context "#self.export_header" do
    subject { Interactions::ProfileUpdate.export_header }

    it { should be_a Array }
  end

  context "#self.export_header" do
    subject { Interactions::ProfileUpdate.export_fields }

    it { should be_a Array }
  end

  its(:interaction_name) { should be_a String }
  its(:summary) { should be_a String }

  it "creates an interaction when recruit updates profile" do
    @interaction.should be_a(Interactions::ProfileUpdate)
    @interaction.person.should == @recruit
  end

  it "stores changed profile fields" do
    @interaction.changed_profile_fields.should =~ ["first_name", "last_name", "searchable_name", "sortable_name"]
  end
end
