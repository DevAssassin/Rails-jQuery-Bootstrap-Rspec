require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Recruiting Calendar Items", %q{
  In order to notify my coaches of relevant information
  As a compliance officer
  I want to create, edit, and view recruiting calendar items
} do

  background do
    log_in
    change_scope @account
  end

  scenario "Creating a recruiting calendar item" do
    visit new_program_recruiting_calendar_item_path(@program)

    fill_in 'Start time', with: 1.week.ago
    fill_in 'End time', with: 1.week.from_now
    fill_in 'Message', with: "Don't call more than thrice in September"
    select "Notice (Blue)", :from => 'Message type'

    click_button "Save"

    page.should have_selector('ul.calendar-items li')

    within('ul.calendar-items') do
      page.should have_content('Notice')
    end

    change_scope @program
    visit dashboard_path(@program)
    within(".globalmsg .bluenotice") do
      page.should have_content("Don't call more than thrice in September")
    end
  end

  scenario "Editing a recruiting calendar item" do
    item = Fabricate(:recruiting_calendar_item, :program => @program, :start_time => 10.weeks.ago, :end_time => 6.weeks.ago, :message_type => :notice, :message => "Original Message")

    visit edit_program_recruiting_calendar_item_path(@program, item)

    fill_in 'Start time', with: 1.week.ago
    fill_in 'End time', with: 1.week.from_now
    select "Alert (Red)", :from => 'Message type'
    fill_in 'Message', with: 'Some other message'

    click_button "Save"

    within('ul.calendar-items') do
      page.should have_content('Alert')
    end

    change_scope @program
    visit dashboard_path(@program)

    within(".globalmsg .redalert") do
      page.should have_content("Some other message")
    end
  end

end
