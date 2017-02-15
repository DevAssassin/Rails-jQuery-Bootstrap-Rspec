require 'spec_helper'

describe Interaction do
  it "defaults to the current time for interaction_time" do
    time = Time.local(2010, 12, 17, 14, 42, 0)

    Timecop.freeze(time) do
      interaction = Interaction.new

      interaction.interaction_time.should == time
    end
  end

  it "doesn't override an existing time" do
    time = Time.parse("1/1/2011 0:00:00Z")

    interaction = Fabricate(:interaction)
    interaction.interaction_time = time
    interaction.save

    interaction.reload
    interaction.interaction_time.should == time
  end

  it "can be created by type" do
    klass = Interaction.find_subclass("Comment")

    klass.should == Interactions::Comment
  end

  it "can't escape the module" do
    bad = lambda { Interaction.find_subclass("::Kernel") }

    bad.should raise_error
  end

  it "returns the humanized class name" do
    int = Fabricate(:comment_interaction)

    int.interaction_type.should == "Comment"
  end

  context "when searching by account or program" do
    let(:account) { person.account }
    let(:program) { person.program }
    let(:person) { Fabricate(:recruit) }
    let!(:interaction) { Fabricate(:interaction, :person => person) }

    it "finds by account" do
      Interaction.where_account_or_program(account).first.should == interaction
    end

    it "finds by program" do
      Interaction.where_account_or_program(program).first.should == interaction
    end
  end

  context "when finding date ranges of interactions" do
    let!(:interaction) { Fabricate(:interaction, interaction_time: Time.parse('2011-02-05')) }
    let!(:other_interaction) { Fabricate(:interaction, interaction_time: Time.parse('2011-02-25')) }

    it "finds both interactions in February" do
      interactions = Interaction.between_times("2011-02-01".."2011-03-01").to_a

      interactions.should =~ [interaction, other_interaction]
    end

    it "finds only the first in the first half of February" do
      interactions = Interaction.between_times("2011-02-01".."2011-02-14").to_a

      interactions.should =~ [interaction]
    end
  end

  context "when deleting a phone call interaction" do
    let!(:edit) { Fabricate(:edited_phone_call_interaction, :phone_call => Fabricate(:phone_call_interaction)) }
    it "should also delete the edited phone call interactions" do
      edit.phone_call.destroy
      Interaction.where(:_id => edit.id).count.should == 0
    end
  end
end
