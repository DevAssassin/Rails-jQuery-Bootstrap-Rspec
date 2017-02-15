require 'acceptance/acceptance_helper'

feature "Reports", %q{
  In order to get information about interactions
  As a coach
  I want to build and run reports
} do

  background do
    log_in
  end

  scenario "Creating a new report" do
    visit new_report_path

    fill_in "report_name", :with => "TestReport"
    select "Email", :from => "Interaction type"
    fill_in "report_start_date", :with => "March 1, 2011"
    fill_in "report_end_date", :with => "March 31, 2011"

    click_button "Save"

    page.should have_content "TestReport"
  end

  scenario "Creating a new report without an end date" do
    visit new_report_path

    page.should have_content "End date"
    page.should_not have_content "End date*"

    fill_in "report_name", :with => "TestReportNoEndDate"
    select "Email", :from => "Interaction type"
    fill_in "report_start_date", :with => "March 1, 2011"
    fill_in "report_end_date", :with => ""

    click_button "Save"

    page.should have_content "TestReportNoEndDate"
  end

  scenario "Filtering the Reports through users", :js => true do
    report = Fabricate(:comment_report)
    report.user_id = @user.id
    report.program_id = @program.id
    report.save
    visit reports_path
    select "All Reports", :from => "user_filter"
    page.should have_content "TestReport"
  end

end
