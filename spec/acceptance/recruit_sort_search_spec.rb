require 'acceptance/acceptance_helper'

feature "Recruits", %q{
  Searching for Recruit list
} do

  background do
    log_in
    @phil = Fabricate(:recruit, :first_name => "Phil", :last_name => "Brabbs", :program => @program, :graduation_year => Date.today.year)
    @other_recruit = Fabricate(:recruit, :program => @program)
  end

  scenario "Searching through search box should return recruit list with the first name matching the keyword", :js => true do
    visit recruits_path

    within '#searchbox' do
      fill_in "search", :with => "phil"
      page.driver.browser.execute_script("$('#search_person').trigger('blur')")
    end

    within '#person-list' do
      page.should have_content "Phil"
      page.should have_no_content "Smith"
    end
  end

  scenario "Searching for tag should return recruit list with the searched tag", :js => true do
    recruit = @phil
    recruit.program_tags_array = ["boy","girl"]
    recruit.save!

    visit recruits_path

    within '#tag-filter-inline' do
      fill_in "tag_filter", :with => "boy"
      page.driver.browser.execute_script("$('input[name=\"tag_filter\"]').trigger('blur')")
    end

    within '#person-list' do
      page.should have_content "Phil"
      page.should have_no_content "Smith"
    end
  end

  scenario "Searching for grad year should return recruits with that grad year", :js => true do
    visit recruits_path

    within '#grad-year-filter' do
      select Date.today.year.to_s
      page.driver.browser.execute_script("$('select[name=\"grad_year_filter\"]').trigger('blur')")
    end

    within '#person-list' do
      page.should have_content "Phil"
      page.should have_no_content "Smith"
    end
  end
end
