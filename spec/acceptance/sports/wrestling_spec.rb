require 'acceptance/acceptance_helper'

feature "Wrestling Recruits", %q{
  In order to better manage my wrestling recruits
  As a coach
  I want to be able collect sport-specific information
} do

  background do
    log_in(:program => Fabricate(:wrestling_program))
  end

  it_behaves_like "Recruit"

  scenario "Creating a new wrestling recruit" do
    create_recruit do
      select('133', :from => "person_projected_college_weight")
    end

    within('#athletic-tab') do
      page.should have_content("133")
    end
  end
end
