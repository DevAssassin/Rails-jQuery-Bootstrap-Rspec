require 'acceptance/acceptance_helper'

feature "Coaches Tab", %q{
  In order to streamline my compliance process
  As a compliance officer
  I want to be able to interact with coaches at my institution
} do

  background do
    log_in
  end

  scenario "Creating a coach manually" do
    create_coach

    page.should have_content("Lloyd")
    page.should have_content("Carr")
  end

  scenario "Viewing a coach in the table", :js => true do
    coach = Fabricate(:coach, :program => @program)

    visit coaches_path

    page.should have_content(coach.first_name)
    page.should have_content(coach.last_name)
  end

  scenario "Printing staff contact list" do
    coach = Fabricate(:coach, :program => @program)
    visit print_staff_path(:people => "coaches")
    page.should have_content(coach.name)
  end

end
