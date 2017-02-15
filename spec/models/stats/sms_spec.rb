require 'spec_helper'

describe Stats::Sms do

  before :each do
    Interactions::Sms.any_instance.stub(:validate_person_smsable).and_return(true)

    @a = Fabricate(:account)
    @p = Fabricate(:program, :account => @a)
    @u = Fabricate(:user)
    Stats::Sms.log Fabricate(:sms_interaction, :person => Fabricate(:person, :account => @a, :program => @p), :user => @u)
    Stats::Sms.log Fabricate(:sms_interaction, :person => Fabricate(:person, :account => @a, :program => @p))
    Stats::Sms.log Fabricate(:sms_interaction, :user => @u)
  end

  it "should count messages per account" do
    Stats::Sms.accounts.should include({ 'account_id' => @a.id, 'count' => 2 })
  end

  it "should count messages per program" do
    Stats::Sms.programs(@a).should include({ 'program_id' => @p.id, 'count' => 2 })
  end

  it "should count messages per user" do
    Stats::Sms.user(@u).should == 2
  end

end
