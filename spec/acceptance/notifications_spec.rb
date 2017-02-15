require 'acceptance/acceptance_helper'

feature "Notifications", %q{
  In order to communicate with our customers
  As a scoutforce employee
  I want to be able to send notifications to our users
} do

  background do
    log_in
  end

  scenario "Viewing a notification" do
    Fabricate(:notification, text: "hello there")

    visit root_path

    page.should have_content("hello there")
  end

  scenario "Dismissing a notification" do
    notification = Fabricate(:notification, text: "hello there")

    visit root_path

    within("#notification-#{notification.id}") do
      find("a.dismiss").click
    end

    page.should have_no_content("hello there")

    visit root_path

    page.should have_no_content("hello there")
  end

end
