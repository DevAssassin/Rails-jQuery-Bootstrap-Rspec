require 'spec_helper'

describe Invitation do
  context "validation" do
    before :each do
      @invite = Invitation.new(Fabricate(:account))
    end
    it { @invite.should validate_presence_of :recipient_first_name }
    it { @invite.should validate_presence_of :recipient_last_name }
    it { @invite.should validate_presence_of :recipient_email }
    it { @invite.should_not validate_presence_of :program_ids }
  end
end
