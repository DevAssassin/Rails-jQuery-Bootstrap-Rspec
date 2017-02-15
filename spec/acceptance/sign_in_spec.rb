require 'acceptance/acceptance_helper'

feature "Users", %q{
  In order to sign in to the application
  As a general User
  I want to be able to provide my email address and password
  } do

  background do
    Fabricate(:country, :name => "United States of America")
    Fabricate(:country, :name => "Canada")
    Fabricate(:country)

    @program = Fabricate(:program)
    @user = Fabricate(:user, :email => 'MixCase@test.com')
    @user.programs << @program
    @user.accounts << @program.account

    @account = @program.account
  end

  scenario "Sign in with the exact email" do
    visit new_user_session_path

    fill_in 'user_email', :with => 'MixCase@test.com'
    fill_in 'user_password', :with => 'testtest'

    click_button 'Log in'
    page.should have_content 'Signed in successfully.'
  end

  scenario "Sign in with a lowercase version of the email" do
    visit new_user_session_path

    fill_in 'user_email', :with => 'mixcase@test.com'
    fill_in 'user_password', :with => 'testtest'

    click_button 'Log in'
    page.should have_content 'Signed in successfully.'
  end

  scenario "Sign in with an uppercase version of the email" do
    visit new_user_session_path

    fill_in 'user_email', :with => 'MIXCASE@TEST.COM'
    fill_in 'user_password', :with => 'testtest'

    click_button 'Log in'
    page.should have_content 'Signed in successfully.'
  end
end
