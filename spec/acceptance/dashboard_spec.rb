require 'acceptance/acceptance_helper'

feature "Dashboard", %q{
  In order to get a good idea of my activity
  As a user
  I want to see stuff on the dashboard
} do

  let(:program_person) { Fabricate(:person, :program => @program) }
  let(:account_person) { Fabricate(:person, :account => @account) }

  def setup_activity
    @account_interaction = Fabricate(:email_interaction, :subject => 'Hi acct', :person => account_person)
    @program_interaction = Fabricate(:email_interaction, :subject => 'Hi pgrm', :person => program_person)
    @program_comment_interaction = Fabricate(:comment_interaction, :person => program_person)
  end

  background do
    log_in

    setup_activity
  end

  scenario "viewing Recent Activity on Account dashboard", :js => true do
    change_scope(@account)
    visit account_dashboard_path(@account)
    page.should have_select 'interaction_scope'

    within '.interaction-list' do
      page.should have_content 'Hi acct'
      page.should have_content 'Hi pgrm'
      page.should have_content 'Comment'
    end

    select 'Email', :from => 'interaction_type'

    within '.interaction-list' do
      page.should have_content 'Hi acct'
      page.should have_content 'Hi pgrm'
      page.should have_no_content 'Comment'
    end

    select 'Account-level only', :from => 'interaction_scope'

    within '.interaction-list' do
      page.should have_content 'Hi acct'
      page.should have_no_content 'Hi pgrm'
      page.should have_no_content 'Comment'
    end

    select 'Program-level only', :from => 'interaction_scope'

    within '.interaction-list' do
      page.should have_no_content 'Hi acct'
      page.should have_content 'Hi pgrm'
      page.should have_no_content 'Comment'
    end
  end

  scenario "viewing Recent Activity on Program dashboard", :js => true do
    change_scope(@program)
    visit dashboard_path(@program)

    page.should have_no_select 'interaction_scope'
    within '.interaction-list' do
      page.should have_content 'Hi pgrm'
      page.should have_no_content 'Hi acct'
      page.should have_content 'Comment'
    end

    select 'Email', :from => 'interaction_type'

    within '.interaction-list' do
      page.should have_content 'Hi pgrm'
      page.should have_no_content 'Hi acct'
      page.should have_no_content 'Comment'
    end
  end

end
