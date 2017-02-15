require 'spec_helper'

describe Interactions::Sms do
  its(:interaction_name) { should be_a String }

  context "#execute" do
    before do
      User.any_instance.stub(:can_sms?).and_return(true)
      Interactions::Sms.any_instance.stub(:callback_url).and_return("fake_callback_url")
    end

    it "sends sms via twilio" do
      sms = Fabricate.build(:sms_interaction, phone_number: '7349614759', text: "testtest")
      Twilio::Sms.should_receive(:message).with(sms.from, '734-961-4759', 'testtest', "fake_callback_url").and_return({})

      sms.execute
    end

    it "splits SMSs that are longer than 140 characters" do
      lipsum140 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. In id odio sed felis elementum cursus. Quisque vel risus ut purus ullamcorper adipi'
      lipsum20 = 'scing viverra fusce.'
      lipsum = lipsum140 + lipsum20

      sms = Fabricate.build(:sms_interaction, phone_number: '7349614759', text: lipsum)

      Twilio::Sms.should_receive(:message).with(sms.from, '734-961-4759', lipsum140, "fake_callback_url").and_return({})
      Twilio::Sms.should_receive(:message).with(sms.from, '734-961-4759', lipsum20, "fake_callback_url").and_return({})

      sms.execute
    end

    it "logs the sms in the stats if twilio response is 'sent' and it has not been logged yet" do
      sms = Fabricate.build(:sms_interaction)
      Twilio::Sms.stub(:message).and_return({"TwilioResponse" => {"SMSMessage" => {"Status" => "sent"}}})
      sms.already_logged = false

      Stats::Sms.should_receive(:log).with(sms)
      sms.execute
    end

    it "does not log the sms in the stats if twilio response is 'sent' and it has already been logged" do
      sms = Fabricate.build(:sms_interaction)
      Twilio::Sms.stub(:message).and_return({"TwilioResponse" => {"SMSMessage" => {"Status" => "sent"}}})
      sms.already_logged = true

      Stats::Sms.should_not_receive(:log).with(sms)
      sms.execute
    end

    it "does not log the sms in the stats if twilio response is not 'sent' and it has not already been logged" do
      sms = Fabricate.build(:sms_interaction)
      Twilio::Sms.stub(:message).and_return({"TwilioResponse" => {"SMSMessage" => {"Status" => "failed"}}})
      sms.already_logged = false

      Stats::Sms.should_not_receive(:log).with(sms)
      sms.execute
    end

  end

  context "validating if recipient can be SMSed" do
    let(:person) { Fabricate(:person) }
    let(:sms) { Fabricate.build(:sms_interaction, person: person) }

    it "doesn't allow SMSes if the person is not SMSable" do
      person.stub(:smsable_by?).with(anything).and_return(false)

      sms.should_not be_valid
    end

    it "allows SMSes if the person is SMSable" do
      person.stub(:smsable_by?).and_return(true)

      sms.should be_valid
    end
  end
end
