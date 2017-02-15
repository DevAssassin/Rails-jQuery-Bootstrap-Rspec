require 'acceptance/acceptance_helper'

feature "Cross Country Recruits", %q{
  In order to better manage my cross country recruits
  As a coach
  I want to be able collect sport-specific information
} do

  background do
    log_in(:program => Fabricate(:cross_country_program))
  end

  it_behaves_like "Recruit"

  scenario "Creating a new cross country recruit" do
    create_recruit do
      fill_in 'person_individual_accomplishments', :with => 'aaaaa'
      fill_in('person_num_years_trained_competitively', :with => "345")
    end

    within('#athletic-tab') do
      page.should have_content('aaaaa')
      page.should have_content("345")
    end
  end
end
