require 'acceptance/acceptance_helper'

feature "Recruits", %q{
  In order to invite new/existing users
  As a User
  I want to be able to invite users
} do

  background do
    log_in
  end

  scenario "Inviting new user" do
    change_scope(@account)

    program1 = Fabricate(:baseball_program, :name => "Baseball Program")
    program2 = Fabricate(:soccer_program, :name => "Soccer Program")

    @account.programs += [program1, program2]

    visit users_invite_path

    fill_in 'invitation_recipient_first_name', :with => 'Recruit'
    fill_in 'invitation_recipient_last_name', :with => 'Smith'
    fill_in 'invitation_recipient_email', :with => '063bct521@ioe.edu.np'
    check program1.name
    check program2.name

    click_button 'Send'

    User.last.email.should == "063bct521@ioe.edu.np"
    [program1, program2].each { |p| User.last.program_ids.should include(p.id) }
    User.last.accounts.should_not include(@account)
    page.should have_content("An Invitation Email has been sent to 063bct521@ioe.edu.np") # TODO: Remove? This is a brittle test.

    # sign out
    visit destroy_user_session_path

    visit user_invite_sign_up_path(User.last.authentication_token)

    fill_in 'First name', :with => "Pink"
    fill_in 'Last name', :with => "Floyd"
    fill_in 'Password', :with => "secret"
    fill_in 'Password confirmation', :with => "secret"

    click_button 'Save'

    current_path.should == program_path(program1)
  end

  scenario "Inviting existing user" do
    change_scope(@account)

    program1 = Fabricate(:baseball_program, :name => "Baseball Program")
    program2 = Fabricate(:soccer_program, :name => "Soccer Program")

    @account.programs += [program1, program2]

    invitee = Fabricate(:user)

    visit users_invite_path

    fill_in 'invitation_recipient_first_name', :with => 'Recruit'
    fill_in 'invitation_recipient_last_name', :with => 'Smith'
    fill_in 'invitation_recipient_email', :with => invitee.email
    check program1.name
    check program2.name
    click_button 'Send'

    invitee.reload

    [program1,program2].each { |p| invitee.program_ids.should include(p.id) }
    page.should have_content("An Invitation Email has been sent to #{invitee.email}") # TODO: Remove? This is a brittle test.
  end

  scenario "Inviting user to account", :js => true do
    change_scope(@account)

    program1 = Fabricate(:baseball_program, :name => "Baseball Program")
    program2 = Fabricate(:soccer_program, :name => "Soccer Program")

    @account.programs += [program1, program2]

    visit users_invite_path

    fill_in 'invitation_recipient_first_name', :with => 'Recruit'
    fill_in 'invitation_recipient_last_name', :with => 'Smith'
    fill_in 'invitation_recipient_email', :with => "a1@b2.local"
    check :invitation_recipient_account_level

    click_button 'Send'

    [program1,program2].each { |p| User.last.programs.should include(p) }
    User.last.accounts.should include(@account)
  end

  scenario "Inviting user to program" do
    visit users_invite_path

    fill_in 'invitation_recipient_first_name', :with => 'Recruit'
    fill_in 'invitation_recipient_last_name', :with => 'Smith'
    fill_in 'invitation_recipient_email', :with => "a123@b245.local"

    click_button 'Send'

    User.where(:email => "a123@b245.local").first.programs.should include(@program)

  end

  scenario "Inviting and removing user to account from users table", :js => true do
    user = Fabricate(:user)
    user.programs << @program
    user.save

    change_scope(@account)
    visit users_path

    within "#user-row-#{user.id}" do
      click_link "Invite"
    end

    click_button 'Send'
    # If invitation not sent for any *new* programs or account...
    current_path.should == users_path
    page.should have_content "No invitation sent"

    # Now, invite to account-level
    within "#user-row-#{user.id}" do
      click_link "Invite"
    end

    # Make sure inputs are disabled

    check :invitation_recipient_account_level
    click_button 'Send'

    current_path.should == users_path
    page.should have_content "has been sent"

    within "#user-row-#{user.id}" do
      page.should have_content @account.name

      # Revoke account-level access
      accept_js_confirm do
        click_link "revoke-#{user.id}-Account-#{@account.id}"
      end
    end

    current_path.should == users_path
    page.should have_content user.name
    within "#user-row-#{user.id}" do
      page.should have_no_content @account.name
    end
  end

  scenario "removing a user's access" do
    user = Fabricate(:user, :first_name => "Removeman")
    user.programs << @program
    user.save

    visit users_path

    within("#user-row-#{user.id}") do
      click_link "Remove"
    end

    within "table" do
      page.should have_content(@user.first_name)
      page.should have_no_content("Removeman")
    end
  end

end
