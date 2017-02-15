require 'acceptance/acceptance_helper'

feature "Scopes", %q{
  In order to be able to access different accounts or programs
  As user
  I want to be able to change scopes
} do

  background do
    log_in(:program => Fabricate(:program, :name => "First Program"))
    @program2 = Fabricate(:program, :name => "Second Program", :account => @account)
    @user.programs << @program2
    @user.save
    @account.name = "Main Account"
    @account.save
  end

  scenario "Switching scope from first to second program", :js => true do
    visit "/"

    within("#header") do
      page.should have_content("First Program")
    end

    select "Second Program", :from => "scope"

    within("#header") do
      page.should have_content("Second Program")
    end
  end

  scenario "Switching scope to account", :js => true do
    visit "/"

    within("#header") do
      page.should have_content("First Program")
    end

    select "Main Account", :from => "scope"

    within("#header") do
      page.should have_content("Main Account")
    end
  end
end
