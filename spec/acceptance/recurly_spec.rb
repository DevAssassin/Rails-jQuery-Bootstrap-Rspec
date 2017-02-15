require 'acceptance/acceptance_helper'

describe "Recurly messages", :type => :request do
  include Rack::Test::Methods

  def app
    Scoutforce::Application
  end

  def new_subscription_xml(options = {})
    date = options[:date] || Time.now.utc.iso8601
    str = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<new_subscription_notification>
  <account>
    <account_code>example@scoutforce.local</account_code>
    <username nil="true"></username>
    <email>example@scoutforce.local</email>
    <first_name>Test</first_name>
    <last_name>Testerman</last_name>
    <company_name nil="true"></company_name>
  </account>
  <subscription>
    <plan>
      <plan_code>max</plan_code>
      <name>Max</name>
    </plan>
    <state>active</state>
    <quantity type="integer">1</quantity>
    <total_amount_in_cents type="integer">14900</total_amount_in_cents>
    <activated_at type="datetime">#{date}</activated_at>
    <canceled_at type="datetime"></canceled_at>
    <expires_at type="datetime"></expires_at>
    <current_period_started_at type="datetime">#{date}</current_period_started_at>
    <current_period_ends_at type="datetime">#{date}</current_period_ends_at>
    <trial_started_at type="datetime">#{date}</trial_started_at>
    <trial_ends_at type="datetime">#{date}</trial_ends_at>
  </subscription>
</new_subscription_notification>
EOF
    str
  end

  before(:each) do
    header 'Accept', 'text/xml'
    header 'Content-Type', 'text/xml'

    ActionMailer::Base.deliveries = []
  end

  it "handles the new_subscription notification" do
    SignUp.should_receive(:provision)
    post sign_up_push_notification_path, new_subscription_xml
  end

  it "provisions a new account when there's an appropriate sign up" do
    signup = Fabricate(:SignUp, :email => "example@scoutforce.local")

    post sign_up_push_notification_path, new_subscription_xml

    Account.all.should have(1).account
    ActionMailer::Base.deliveries.should have(1).email
  end
end
