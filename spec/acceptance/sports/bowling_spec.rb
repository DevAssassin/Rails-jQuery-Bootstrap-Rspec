require 'acceptance/acceptance_helper'

feature "Bowling Recruits", %q{
  In order to better manage my bowling recruits
  As a coach
  I want to be able collect sport-specific information
} do

  background do
    log_in(:program => Fabricate(:bowling_program))
  end

  it_behaves_like "Recruit"

  scenario "Creating a new bowling recruit" do
    create_recruit do
      fill_in 'person_individual_accomplishments', :with => 'aaaaa'
      fill_in('person_high_game', :with => "300")
    end

    within('#athletic-tab') do
      page.should have_content('aaaaa')
      page.should have_content("300")
    end
  end
end
