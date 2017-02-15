require 'spec_helper'

describe EmailAttachment do
  it "generates token when email is saved" do
    email = Fabricate(:email)

    attachment = email.attachments.build
    email.save
    email.reload

    attachment.token.should_not be_blank
  end
end
