require 'acceptance/acceptance_helper'

feature "Soccer Recruits", %q{
  In order to better manage my soccer recruits
  As a coach
  I want to be able collect sport-specific information
} do

  background do
    log_in(:program => Fabricate(:soccer_program))
  end

  it_behaves_like "Recruit"

  scenario "Creating a new soccer recruit" do
    create_recruit do
      fill_in 'person_individual_accomplishments', :with => 'aaaaa'
      select('Goalie', :from => "person_secondary_position")
    end

    within('#athletic-tab') do
      page.should have_content('aaaaa')
      page.should have_content("Goalie")
    end
  end
end
