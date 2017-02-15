require 'spec_helper'

describe PersonObserver do
  context "a person which is part of an account" do
    before do
      @account = Fabricate(:account)
      @person = Fabricate(:person, :account => @account)
    end

    context "with current account activity date set for a year ago" do
      before do
        @account.activity_at = Time.now - 1.year
        @account.save
      end

      context "the person gets updated" do
        before do
          @person.update_attributes(first_name: "NewFirstName")
        end

        it "should update the account activity date" do
          @account.reload
          @account.activity_at.should be_within(1.hour).of(Time.now)
        end
      end
    end
  end
end
