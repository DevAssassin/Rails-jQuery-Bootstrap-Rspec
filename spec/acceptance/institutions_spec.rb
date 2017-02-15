require 'acceptance/acceptance_helper'

shared_examples_for "managing coaches" do
  scenario "Adding Coaches" do
    visit institution_path(institution)

    click_link 'Add Coach'

    fill_in "institution_coach_first_name", with: 'Joseph'
    fill_in 'institution_coach_last_name', with: 'Coachyman'
    fill_in 'institution_coach_office_phone', with: '734-555-1212'
    fill_in 'institution_coach_home_phone', with: '734-555-1234'
    fill_in 'institution_coach_cell_phone', with: '734-555-5555'
    fill_in 'institution_coach_email', with: 'coachyman@school.k12.mi.us'

    click_button 'Save'

    within('.coach-list') do
      page.should have_content('Joseph Coachyman')
      page.should have_content('734-555-1212')
      page.should have_content('734-555-1234')
      page.should have_content('734-555-5555')
      page.should have_content('coachyman@school.k12.mi.us')
    end
  end
end

feature "Institutions", %q{
  In order to keep track of information pertaining to specific schools
  As a coach
  I want to manage institutions in the institutions tab
} do

  background do
    log_in
  end

  context "High Schools" do
    let(:institution) { Fabricate(:school) }

    it_behaves_like "managing coaches"

    scenario "Adding Counselors" do
      visit institution_path(institution)

      click_link 'Add Counselor'

      fill_in "counselor_first_name", with: 'Joseph'
      fill_in 'counselor_last_name', with: 'Counselorman'
      fill_in 'counselor_office_phone', with: '734-555-1212'
      fill_in 'counselor_home_phone', with: '734-555-1234'
      fill_in 'counselor_cell_phone', with: '734-555-5555'
      fill_in 'counselor_email', with: 'counselorman@school.k12.mi.us'

      click_button 'Save'

      within('.counselor-list') do
        page.should have_content('Joseph Counselorman')
        page.should have_content('734-555-1212')
        page.should have_content('734-555-1234')
        page.should have_content('734-555-5555')
        page.should have_content('counselorman@school.k12.mi.us')
      end
    end
  end

  context "Clubs" do
    let(:institution) { Fabricate(:club) }

    it_behaves_like "managing coaches"
  end

  context "Colleges" do
    let(:institution) { Fabricate(:college) }

    it_behaves_like "managing coaches"
  end
end
