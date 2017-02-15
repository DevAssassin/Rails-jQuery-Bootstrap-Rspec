require 'acceptance/acceptance_helper'

feature "Cheer Recruits", %q{
  In order to better manage my cheer recruits
  As a coach
  I want to be able collect sport-specific information
} do

  background do
    log_in(:program => Fabricate(:cheer_program))
  end

  it_behaves_like "Recruit"

  scenario "Creating a new cheer recruit" do
    create_recruit do
      fill_in 'person_individual_accomplishments', :with => 'aaaaa'
      fill_in('person_years_cheerleading', :with => "345")
    end

    within('#athletic-tab') do
      page.should have_content('aaaaa')
      page.should have_content("345")
    end
  end
end
