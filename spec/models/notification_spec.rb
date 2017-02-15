require 'spec_helper'

describe Notification do
  describe "fetching notifications for users" do
    let(:user) { Fabricate(:user) }
    let!(:notification) { Fabricate(:notification) }

    context "with an unread notification" do
      it "returns the notification" do
        Notification.for_user(user).to_a.should =~ [notification]
      end

      it "doesn't return inactive notifications" do
        notification.update_attribute(:active, false)

        Notification.for_user(user).to_a.should =~ []
      end
    end

    context "dismissed notifications" do
      before(:each) do
        notification.dismiss!(user)
      end

      it "marks it dismissed for a user" do
        notification.dismissed?(user).should be_true
      end

      it "doesn't mark it dismissed for other users" do
        notification.dismissed?(Fabricate(:user)).should be_false
      end

      it "doesn't include the notification in the notifications list" do
        Notification.for_user(user).to_a.should =~ []
      end
    end
  end
end
