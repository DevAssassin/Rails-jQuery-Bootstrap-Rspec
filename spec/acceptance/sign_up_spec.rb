require 'acceptance/acceptance_helper'

feature "Recruits", %q{
  In order to signup for an account
  As a general User
  I want to be able to provide my basic information and credit card information and get a package of my choice
  } do

  def fill_in_valid_info
    college = Fabricate(:college, :name => "University of ScoutForce")

    within("#new_sign_up") do
      fill_in 'First name', :with => 'Arthur'
      fill_in 'Last name', :with => 'Dent'
      fill_in 'Email', :with => 'arthur@example.com'
      select('Baseball', :from => 'Sport name')
      fill_in "college", :with => "Scout"
    end

    within("ul.ui-autocomplete") do
      find("a").click
    end
  end

    scenario "Sign Up from sign-in page" do
      visit new_user_session_path
      page.should have_link('Sign up', :href => sign_up_test_path)
    end

    scenario "Fill in invalid info with sport selected" do
      visit sign_up_plans_path(:basic)
      within("#new_sign_up") do
        select('Baseball', :from => 'Sport name')
      end
      click_button('Proceed')
      current_path.should == sign_up_payment_path
      page.should have_selector('#new_sign_up')
      page.should have_selector('.inline-errors')
    end

    scenario "Valid info with no sport selected", :js => true do
      visit sign_up_plans_path(:basic)
      fill_in_valid_info
      within "#new_sign_up" do
        select('', :from => 'Sport name')
      end
      click_button('Proceed')
      current_url.should =~ /#{sign_up_payment_path}/
      page.should have_selector('.inline-errors')
    end

    scenario "Valid info except sport not supported", :js => true do
      visit sign_up_plans_path(:basic)
      fill_in_valid_info
      within("#new_sign_up") do
        select('Water Polo', :from => 'Sport name')
      end
      click_button('Proceed')
      page.should have_content('offer your sport')
    end

    scenario "Choose Single Plan", :js => true do
      visit sign_up_test_path
      click_link('Single')
      find_by_id('sign_up_plan').value.should == 'single'

      fill_in_valid_info

      within("#new_sign_up") do
        click_button('Proceed')
      end

      current_url.should =~ /https:\/\/scoutforce-test\.recurly\.com\/subscribe\/single/
    end

    scenario "Choose Single Plan", :js => true do
      visit sign_up_test_path
      click_link('Single')
      find_by_id('sign_up_plan').value.should == 'single'

      fill_in_valid_info
      within "#new_sign_up" do
        fill_in 'Email', :with => 'ar+th+ur@example.com'
      end

      within("#new_sign_up") do
        click_button('Proceed')
      end

      find_field('account_email').value.should == "ar+th+ur@example.com"
    end

    scenario "When Others is selected for Sport name form action should change for it to redirect to message page", :js => true do
      visit sign_up_test_path
      click_link('Basic')
      current_path.should == sign_up_plans_path("basic")
      find_by_id('sign_up_plan').value.should == 'basic'

      find_by_id('sign_up_other_sport_name_input').should_not be_visible

      within("#new_sign_up") do
        select('Other', :from => 'Sport name')
      end
      page.should have_content("your sport")
      find_by_id('sign_up_other_sport_name_input').should be_visible

      within("#new_sign_up") do
        select('Swimming', :from => 'Sport name')
      end
      find_by_id('sign_up_other_sport_name_input').should_not be_visible

      within("#new_sign_up") do
        select('Baseball', :from => 'Sport name')
      end
      find_by_id('new_sign_up')[:action].should =~ /#{sign_up_payment_path}/
    end

  end
