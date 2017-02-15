require 'spec_helper'

describe Account do
  it "has some coaches" do
    account = Fabricate(:account)
    account.staff << Fabricate(:coach)

    account.staff.should have(1).coach
  end

  it "embeds a form template" do
    account = Fabricate(:account)

    account.build_form_template(:html => "<div>Template</div>")

    account.form_template.html.should == "<div>Template</div>"
  end

  describe "#alert_subscribers" do
    let(:account) { program.account }
    let(:program) { Fabricate(:program) }
    let!(:account_user) { Fabricate(:user, accounts: [account]) }
    let!(:program_user) { Fabricate(:user, programs: [program]) }
    let!(:both_user) { Fabricate(:user, accounts: [account], programs: [program]) }

    it "returns every account-level email" do
      account.alert_subscribers.should =~ [account_user.email, both_user.email]
    end
  end
end
