require 'acceptance/acceptance_helper'

feature "Tags", %q{
  In order to be able to find my recruits
  As a coach
  I want to be able to tag people
} do

  background do
    log_in
  end

  context "on recruits" do
    let(:person) { Fabricate(:baseball_recruit, :program => @program) }
    let(:person2) { Fabricate(:baseball_recruit, :program => @program) }
    subject { person_path(person) }
    let(:list_page) { recruits_path }

    it_behaves_like 'program_taggable'
  end

  context "on rostered players" do
    let(:person) { Fabricate(:rostered_player, :program => @program) }
    let(:person2) { Fabricate(:rostered_player, :program => @program) }
    subject { person_path(person) }
    let(:list_page) { rostered_players_path }

    it_behaves_like 'program_taggable'
  end

  context "on coaches" do
    let(:person) { Fabricate(:coach, :program => @program) }
    let(:person2) { Fabricate(:coach, :program => @program) }
    subject { person_path(person) }
    let(:list_page) { coaches_path }

    it_behaves_like 'program_taggable'
  end

  scenario "Deleting tags" do
    recruit = Fabricate(:baseball_recruit, :program => @program)
    recruit.program_tags = "foo"
    recruit.save

    visit recruits_path

    within('#sidebar .tags') do
      click_link 't'
    end

    current_path.should == recruits_path

    within('#sidebar .tags') do
      page.should_not have_content('foo')
    end

    visit person_path(recruit)

    within('.person-header .tags') do
      page.should_not have_content('foo')
    end
  end

  scenario "Renaming tags" do
    recruit = Fabricate(:baseball_recruit, :program => @program)
    recruit.program_tags = "foo"
    recruit.save

    visit recruits_path

    within('#sidebar .tags') do
      fill_in 'new_tag_name', :with => 'bar'
      click_button "Save"
    end

    current_path.should == recruits_path

    within('#sidebar .tags') do
      page.should_not have_content('foo')
      page.should have_content('bar')
    end

    visit person_path(recruit)

    within('.person-header .tags') do
      page.should_not have_content('foo')
      page.should have_content('bar')
    end
  end

  scenario "Filter using tags with periods or ampersands", :js => true do
    recruit1 = Fabricate(:baseball_recruit, :program => @program)
    recruit1.program_tags_array = ["123","A.B"]
    recruit1.save

    recruit2 = Fabricate(:baseball_recruit, :program => @program)
    recruit2.program_tags = "123"
    recruit2.save

    recruit3 = Fabricate(:baseball_recruit, :program => @program)
    recruit3.program_tags = "A.B"
    recruit3.save

    visit recruits_path

#   TODO: Figure out why Selenium is stripping out ampersands when filling in form
#   within('#search-wrapper') do
#     fill_in 'tag_filter', :with => '12&3'
#   end

    within('#search-wrapper') do
      fill_in 'tag_filter', :with => 'A.B'
      page.driver.browser.execute_script("$('input[name=\"tag_filter\"]').trigger('blur')")
    end

    within('#person-list') do
      page.should have_content(recruit1.first_name)
      page.should have_no_content(recruit2.first_name)
      page.should have_content(recruit3.first_name)
    end
  end

  scenario "Filter using tags with multiple spaces", :js => true do
    recruit1 = Fabricate(:baseball_recruit, :program => @program, :first_name => 'Kevin', :last_name => 'Spacey')
    recruit1.program_tags_array = ["Top tier recruits","normal"]
    recruit1.save

    recruit2 = Fabricate(:baseball_recruit, :program => @program)
    recruit2.program_tags = "normal"
    recruit2.save

    recruit3 = Fabricate(:baseball_recruit, :program => @program)
    recruit3.program_tags = "Top tier recruits"
    recruit3.save

    visit recruits_path
    click_link "Spacey, Kevin"

    click_link "Top tier recruits"

    within('#person-list') do
      page.should have_content(recruit1.first_name)
      page.should have_no_content(recruit2.first_name)
      page.should have_content(recruit3.first_name)
    end
  end

  scenario "Filter using tags with plusses", :js => true do
    recruit1 = Fabricate(:baseball_recruit, :program => @program, :first_name => 'Kevin', :last_name => 'Spacey')
    recruit1.program_tags_array = ["Top+tier+recruits","normal"]
    recruit1.save

    recruit2 = Fabricate(:baseball_recruit, :program => @program)
    recruit2.program_tags = "normal"
    recruit2.save

    recruit3 = Fabricate(:baseball_recruit, :program => @program)
    recruit3.program_tags = "Top+tier+recruits"
    recruit3.save

    visit recruits_path
    click_link "Spacey, Kevin"

    click_link "Top+tier+recruits"

    within('#person-list') do
      page.should have_content(recruit1.first_name)
      page.should have_no_content(recruit2.first_name)
      page.should have_content(recruit3.first_name)
    end
  end

end
