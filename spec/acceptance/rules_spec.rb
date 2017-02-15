require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Interactions", %q{
  In order to log my interactions with a recruit
  As a coach
  I want to create, edit, and view interactions
} do

  background do
    log_in
    change_scope @account
  end

  scenario "Creating a rule" do
    visit new_program_phone_call_rule_path(@program)

    select 'Freshman', from: 'School class'
    fill_in 'Start time', with: '2011-09-01 12:00 am'
    fill_in 'End time', with: '2011-10-01 12:00 am'
    fill_in 'Calls allowed', with: '3'
    select 'week', from: 'Time period'
    fill_in 'Message', with: "Don't call more than thrice in September"

    click_button "Save"

    page.should have_selector('ul.rules li')

    within('ul.rules') do
      page.should have_content('Freshman')
    end
  end

  scenario "Editing a rule" do
    rule = Fabricate(:phone_call_rule, :program => @program)

    visit edit_program_phone_call_rule_path(@program, rule)

    fill_in 'Calls allowed', with: '65536'

    click_button "Save"

    within('ul.rules') do
      page.should have_content('65536')
    end
  end

end
