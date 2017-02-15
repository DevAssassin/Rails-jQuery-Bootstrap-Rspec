require 'acceptance/acceptance_helper'

feature "Exporting people", %q{
  As a user
  I want to be able to export my people
  So that I can use the data elsewhere
} do

  let!(:recruit) { Fabricate(:baseball_recruit, first_name: "Nolan", last_name: "Ryan")}
  let!(:other_recruit) { Fabricate(:baseball_recruit, first_name: "Babe", last_name: 'Ruth')}

  background do
    log_in
  end

  # FIXME: selenium can't really handle file downloads appropriately
  # We'd have to use a js-less test here, which kind of defeats the purpose
  pending "Searching through search box should export the same recruits that are displayed in the list", :js => true do
    visit recruits_path

    within '#searchbox' do
      fill_in "search", :with => "nolan"
      page.driver.browser.execute_script("$('#search_person').trigger('blur')")
    end

    click_link 'Export'

    lines = body.split("\n")
    lines.should have(2).lines
    lines.first.should =~ /first_name/
    lines.last.should =~ /Nolan/
  end
end
