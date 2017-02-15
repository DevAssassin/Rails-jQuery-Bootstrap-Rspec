require 'spec_helper'

describe Interactions::PhoneCall do
  context "#self.export_header" do
    subject { Interactions::PhoneCall.export_header }

    it { should be_a Array }
  end

  context "#self.export_header" do
    subject { Interactions::PhoneCall.export_fields }

    it { should be_a Array }
  end

  #it { should validate_presence_of :duration }

  its(:interaction_name) { should be_a String }

  context "durations" do
    it "parses a human readable duration" do
      @call = Fabricate(:phone_call_interaction)
      @call.duration = "5min 30s"
      @call.duration.should == 330
    end

    it "keeps 0 as 0" do
      @call = Fabricate(:phone_call_interaction)
      @call.duration = "0"
      @call.duration.should == 0
    end
  end

  context "with rules engine enabled" do
    let(:account) { Fabricate(:full_account) }
    let(:program) { Fabricate(:baseball_program, account: account) }
    let(:phone_call) { Fabricate(:phone_call_interaction, person: person) }

    context "for recruits" do
      let(:person) { Fabricate(:baseball_recruit, account: account, program: program)}

      before(:each) do
        ActionMailer::Base.deliveries = []
      end

      it "checks the rules engine" do
        phone_call.should_receive(:check_rules!).and_return([])

        phone_call.execute
      end

      it "sends an alert violated email" do
        alert = Fabricate(:alert_interaction)
        engine = double(RuleEngine)
        engine.stub(:alerts).and_return([alert])
        phone_call.stub(:_rule_engine).and_return(engine)

        phone_call.execute

        ActionMailer::Base.deliveries.should have(1).email
      end
    end

    context "for non-recruits" do
      let(:person) { Fabricate(:person, account: account, program: program) }

      it "does not check the rules engine" do
        phone_call.should_not_receive(:check_rules!)

        phone_call.execute
      end
    end
  end

  context "with rules engine disabled" do
    let(:account) { Fabricate(:basic_account) }
    let(:program) { Fabricate(:baseball_program, account: account) }
    let(:person) { Fabricate(:baseball_recruit, account: account, program: program)}
    let(:phone_call) { Fabricate(:phone_call_interaction, person: person) }

    it "does not check the rules engine" do
      phone_call.should_not_receive(:check_rules!)

      phone_call.execute
    end
  end
end
