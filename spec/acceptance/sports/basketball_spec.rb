require 'acceptance/acceptance_helper'

feature "Basketball Recruits", %q{
  In order to better manage my basketball recruits
  As a coach
  I want to be able collect sport-specific information
} do

  background do
    log_in(:program => Fabricate(:basketball_program))
  end

  it_behaves_like "Recruit"

  scenario "Creating a new basketball recruit" do
    create_recruit do
      fill_in 'person_individual_accomplishments', :with => 'aaaaa'
      fill_in('person_points_per_game', :with => "12345")
    end

    within('#athletic-tab') do
      page.should have_content('aaaaa')
      page.should have_content("12345")
    end
  end
end
