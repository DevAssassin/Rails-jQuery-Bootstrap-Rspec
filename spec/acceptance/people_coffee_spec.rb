require 'acceptance/acceptance_helper'

feature "People coffee script", %q{
  In order to track my recruits
  As a user
  I want to be able to manage people in a javascripty way
} do

  background do
    log_in
  end

  scenario "Showing/Hiding the conversion form", :js => true do
    person = Fabricate(:person, :program => @program)
    visit person_path(person)
    within(".actions") do
      find_link('Convert').should be_visible
      find_button('Perform Conversion').should_not be_visible
      click_on 'Convert'
      find_button('Perform Conversion').should be_visible
      find_link('Convert').should_not be_visible
      click_on 'Cancel'
      find_link('Convert').should be_visible
      find_button('Perform Conversion').should_not be_visible
    end
  end
end
