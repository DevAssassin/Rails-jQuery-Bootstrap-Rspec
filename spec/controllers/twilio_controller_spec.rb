require 'spec_helper'

describe TwilioController do
  describe '#complete' do
    it "configures the resulting interaction appropriately" do
      RuleEngine.any_instance.stub(:can_interact?).and_return(false)
      interaction = Fabricate(:place_call_interaction)

      post(:complete, :interaction_id => interaction, :CallDuration => '123')

      interaction.reload

      interaction.status.should == 'Completed'
      interaction.countable.should be_true
      interaction.duration.should == 123
    end
  end
end
