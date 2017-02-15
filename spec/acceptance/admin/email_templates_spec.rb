require 'acceptance/acceptance_helper'

feature "Email Templates Admin", %q{
  In order to be able to allow users of an account to use a standard template
  As a scoutforce admin
  I want to be able to manage email templates
} do

  background do
    log_in(:user => Fabricate(:admin))
  end

  scenario "Creating a new email template at the account level" do
    visit admin_account_email_templates_path(@account)

    click_link 'New Email template'
    fill_in 'Name', :with => "account level"
    click_button 'Save'

    page.should have_content 'Email Templates'
    page.should have_content @account.name
    page.should have_content 'account level'
    @account.email_templates.first.name.should == 'account level'
    @program.email_templates.count.should == 0
  end

  scenario "Creating a new email template at the program level" do
    visit admin_account_program_email_templates_path(@account, @program)

    click_link 'New Email template'
    fill_in 'Name', :with => "Program level"
    click_button 'Save'

    page.should have_content 'Email Templates'
    page.should have_content @program.name
    page.should have_content 'Program level'
    @program.email_templates.first.name.should == 'Program level'
    @account.email_templates.count.should == 0
  end
end
