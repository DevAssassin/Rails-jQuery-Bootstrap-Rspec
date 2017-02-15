require 'acceptance/acceptance_helper'

feature "Assigning", %q{
  In order to be able to find my recruits
  As a coach
  I want to be able to assign recruits to different coaches
} do

  background do
    log_in
  end

  scenario "Assigning a recruit from the recruit" do
    recruit = Fabricate(:baseball_recruit, :program => @program)

    visit person_path(recruit)

    within('.assignment-form') do
      check("assign_id_#{@user.id}")
      click_button("Save")
    end

    current_path.should == person_path(recruit)

    find("#assign_id_#{@user.id}").should be_checked
  end

  scenario "Assigning a recruit from the recruit creation page" do
    create_recruit do
      check "person_watcher_ids_#{@user.id}"
    end

    find("#assign_id_#{@user.id}").should be_checked
  end

  scenario "Mass assigning a recruit", :js => true do

    joe = Fabricate(:baseball_recruit, :program => @program)
    sam = Fabricate(:baseball_recruit, :program => @program)
    recruits = [joe, sam]

    visit recruits_path

    recruits.each do |recruit|
      within("#person-row-#{recruit.id}") do
        check("people[]")
      end
    end

    click_button 'Assign'
    within('.assignment-form') do
      check("assign_id_#{@user.id}")
      click_button("Save")
    end

    current_path.should == recruits_path

    recruits.each do |recruit|
      visit person_path(recruit)
      find("#assign_id_#{@user.id}").should be_checked
    end
  end
end
