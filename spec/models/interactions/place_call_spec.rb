require 'spec_helper'

describe Interactions::PlaceCall do
  let(:user) { Fabricate(:user) }
  let(:person) { Fabricate(:baseball_recruit) }

  before(:each) do
    subject.user = user
    subject.person = person
  end

  it 'validates true if there are no rules violations' do
    RuleEngine.any_instance.stub(:can_interact?) { true }
    subject.should be_valid
    subject.save.should be_true
  end

  it 'validates false if there are rules violations' do
    RuleEngine.any_instance.stub(:can_interact?) { false }
    subject.should_not be_valid
    subject.save.should be_false
  end

  context 'the user has a verified cell phone number 5555555555' do
    before do
      user.stub!(:cell_phone_verified?) { true }
      user.cell_phone = '5555555555'
    end

    its(:caller_id) { should == '555-555-5555'}
  end

  context 'the user has an unverified phone number' do
    before do
      user.stub(:cell_phone_verified?) { false }
      user.cell_phone = '5555555555'
    end

    its(:caller_id) { should == '734-606-4913' }
  end

  context "call has already been placed" do
    it "#execute should not make a Twilio call" do
      account = Fabricate(:account, :rules_engine? => false)
      subject.account = account
      subject.placed = true
      Twilio::Call.should_not_receive(:make)

      subject.execute
    end
  end

  context "call has not already been placed" do
    it "#execute should make a Twilio call" do
      account = Fabricate(:account, :rules_engine? => false)
      subject.account = account
      subject.placed = false
      request = double()
      request.stub(:host) { 'http://www.scoutforce.com' }
      request.stub(:port) { '3000' }
      Twilio::Call.stub(:make) { true }
      Twilio::Call.should_receive(:make)

      subject.execute(:request => request)
    end
  end
end
