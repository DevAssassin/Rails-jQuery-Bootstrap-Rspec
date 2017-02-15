require 'acceptance/acceptance_helper'

feature "User Admin", %q{
  In order to be able to handle customer requests
  As a scoutforce admin
  I want to be able to manage users
} do

  background do
    log_in(:user => Fabricate(:admin))
    ActionMailer::Base.deliveries = []
  end

  scenario "Inviting a new user to a program" do
    visit invite_admin_account_program_users_path(@account, @program)

    fill_in 'email', :with => "test-invite@scoutforce.local"
    click_button 'Invite'

    ActionMailer::Base.deliveries.should_not be_empty

    @program.users.last.email.should == 'test-invite@scoutforce.local'
  end

  scenario "Inviting a new user to a account" do
    visit invite_admin_account_users_path(@account)

    fill_in 'email', :with => "test-invite@scoutforce.local"
    click_button 'Invite'

    ActionMailer::Base.deliveries.should_not be_empty

    @account.users.last.email.should == 'test-invite@scoutforce.local'
  end

  scenario "Inviting a new user to an account with a mixed case email" do
    visit invite_admin_account_users_path(@account)

    fill_in 'email', :with => "tEst-Invite@scoutforce.local"
    click_button 'Invite'

    ActionMailer::Base.deliveries.should_not be_empty

    @account.users.last.email.should == 'test-invite@scoutforce.local'
  end
end
