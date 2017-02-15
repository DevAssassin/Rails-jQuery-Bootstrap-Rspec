require 'acceptance/acceptance_helper'

feature "Emailing", %q{
  In order to be able communicate with my recruits
  As a coach
  I want to be able to send emails to recruits and track them in my system
} do

  background do
    log_in

    ActionMailer::Base.deliveries = []
  end

  scenario "Emailing a single recruit" do
    recruit = Fabricate(:baseball_recruit, :program => @program)

    visit person_path(recruit)

    click_link "Compose Email"

    fill_in "Subject", :with => "subj"
    fill_in "Body", :with => "body"

    click_button "Send"

    ActionMailer::Base.deliveries.should_not be_empty

    visit person_path(recruit)

    within('ul.interactions .interaction') do
      page.should have_content('Email')
      page.should have_content('subj')
    end
  end

  scenario "Copying the sender" do
    recruit = Fabricate(:baseball_recruit, :program => @program)

    visit person_path(recruit)

    click_link "Compose Email"

    fill_in "Subject", :with => "subj"
    fill_in "Body", :with => "body"
    check "Copy sender"

    click_button "Send"

    ActionMailer::Base.deliveries.should have(2).emails

    email = ActionMailer::Base.deliveries.last

    email.to.should include(@user.email)
  end

  scenario "Getting email signature automatically from current user", :js=>true do
    recruit = Fabricate(:baseball_recruit, :program => @program)
    visit recruits_path

    within("#person-row-#{recruit.id}") do
      check("people[]")
    end
    within ('.actions') do
      click_button 'Email'
    end

    page.should have_content(@user.email_signature)

  end

  # See acceptance/tasks_spec.rb for more extensive testing of
  # scheduling functionality and note why it's there
  scenario "Scheduling an email", :js => true do
    Delayed::Worker.delay_jobs = true
    recruit = Fabricate(:baseball_recruit, :program => @program)
    visit new_email_path(:to => [recruit.id])

    fill_in "Subject", :with => "subj"
    click_link "Schedule to send later"
    select "2", :from => "email_schedule_attributes_amount"
    select "months", :from => "email_schedule_attributes_unit"
    # Page should not allow selecting 'before due' since this is not a task email
    page.should have_no_select("email_schedule_attributes_relative_to")

    click_button "Schedule"

    within '.notice' do
      page.should have_content "Your email was scheduled successfully"
    end
    current_path.should == scheduled_emails_path
    page.should have_link "subj"
    page.should have_content (Time.now + 2.months).to_formatted_s.gsub(/\s+/, ' ')

    click_link "subj"
    accept_js_confirm do
      click_link "Delete"
    end

    current_path.should == scheduled_emails_path
    within '.notice' do
      page.should have_content "deleted"
    end
    page.should have_no_link "subj"
  end
end
