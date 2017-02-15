require 'acceptance/acceptance_helper'

feature "Sales Recruits", %q{
  In order to better manage my sales leads
  As a salesperson
  I want to be able collect sales-specific information
} do

  background do
    log_in(:program => Fabricate(:sales_program))
  end

  scenario "Creating a new sales leads" do
    create_recruit do
      fill_in('person_sport_name', :with => "12345")
    end

    within('#athletic-tab') do
      page.should have_content("12345")
    end

    # make sure alternate statuses are working
    page.should have_content "Cold Lead"
  end
end
