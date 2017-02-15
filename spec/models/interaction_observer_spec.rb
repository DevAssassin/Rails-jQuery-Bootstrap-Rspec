require 'spec_helper'

describe InteractionObserver do
  context "a person which is part of an account" do
    before do
      @interaction = Fabricate(:interaction)
      @account = @interaction.account
    end

    context "with current account activity date set for a year ago" do
      before do
        @account.activity_at = Time.now - 1.year
        @account.save
      end

      context "the interaction gets updated" do
        before do
          @interaction.update_attributes(text: "New Text")
        end

        it "should update the account activity date" do
          @account.reload
          @account.activity_at.should be_within(1.hour).of(Time.now)
        end
      end
    end
  end
end
