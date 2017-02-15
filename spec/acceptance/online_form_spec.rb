require 'acceptance/acceptance_helper'

feature "Online form", %q{
  In order to have recruits added to my program through public url
  As a coach
  I want to have an online recruit form for adding recruits
} do

  background do
    @account = Fabricate(:account)
    @program = Fabricate(:program, :account => @account)
    Fabricate(:country, :name => "United States of America")
    Fabricate(:country, :name => "Canada")
  end

  scenario "Filling out the form with valid data" do
    @program.thank_you_message = "This is a test"
    @program.notify_recruit_form_string = "hi@example.com, bye@example.com,"
    @program.save

    visit online_form_path(@program)
    page.should have_content 'Online Recruit Form'

    fill_in 'person_first_name', :with => 'Phil'
    fill_in 'person_last_name', :with => 'Brabbs'
    fill_in 'person_email', :with => 'brabbs@dominat.or'
    fill_in 'person_nickname', :with => 'Dominator'
    fill_in 'person_address_attributes_street', :with => '123 Main St.'
    fill_in 'person_email', :with => 'brabbs@example.com'

    lambda {
      click_button 'Send'
    }.should change(ActionMailer::Base.deliveries, :count).by(3)
    ActionMailer::Base.deliveries[-2].to.should == [ "bye@example.com" ]
    ActionMailer::Base.deliveries[-2].subject.should =~ /created a profile/

    recruit = @program.recruits.first

    recruit.first_name.should == 'Phil'
    recruit.last_name.should == 'Brabbs'
    recruit.nickname.should == 'Dominator'
    page.should have_content(@program.thank_you_message)
  end

  scenario "Filling out the form with invalid data" do
    @program.thank_you_message = "This is a test"
    @program.notify_recruit_form_string = "hi@example.com, bye@example.com,"
    @program.save

    visit online_form_path(@program)

    fill_in 'person_first_name', :with => nil
    fill_in 'person_last_name', :with => 'Brabbs'
    fill_in 'person_nickname', :with => 'Dominator'
    fill_in 'person_address_attributes_street', :with => '123 Main St.'

    lambda {
      click_button 'Send'
    }.should change(ActionMailer::Base.deliveries, :count).by(0)

    page.should have_content "First Name*can't be blank"
  end

  scenario "Updating profile with valid data" do
    recruit = Fabricate(:recruit, :program => @program, :account => @account)
    @program.thank_you_message = "Testing"
    @program.notify_recruit_form_string = "hi@example.com, bye@example.com,"
    @program.save

    visit invited_person_path(recruit.authentication_token)

    fill_in 'person_first_name', :with => 'Steve'
    fill_in 'person_last_name', :with => 'McDudersauce'

    lambda {
      click_button 'Send'
    }.should change(ActionMailer::Base.deliveries, :count).by(3)
    ActionMailer::Base.deliveries[-2].to.should == [ "bye@example.com" ]
    ActionMailer::Base.deliveries[-2].subject.should =~ /updated their profile/

    recruit = @program.recruits.first
    recruit.first_name.should == 'Steve'
    recruit.last_name.should == 'McDudersauce'
    page.should have_content("Testing")

    interaction = Interaction.last

    log_in(:program => @program)
    within '.interaction-list .type' do
      page.should have_content "Updated"
    end

    within '.interaction-list .name' do
      page.should have_content "Steve McDudersauce"
    end
  end

  scenario "Updating profile with invalid data" do
    recruit = Fabricate(:recruit, :program => @program, :account => @account)
    @program.thank_you_message = "Testing"
    @program.notify_recruit_form_string = "hi@example.com, bye@example.com,"
    @program.save

    visit invited_person_path(recruit.authentication_token)

    fill_in 'person_first_name', :with => nil
    fill_in 'person_last_name', :with => 'McDudersauce'

    lambda {
      click_button 'Send'
    }.should change(ActionMailer::Base.deliveries, :count).by(0)

    page.should have_content "First Name*can't be blank"
  end

  scenario "Filling out online form" do
    visit online_form_path(@program)
    page.should have_no_css("#person_notes")
  end

  scenario "Updating profile with private notes" do
    recruit = Fabricate(:recruit, :program => @program, :notes => "This recruit sucks")
    visit invited_person_path(recruit.authentication_token)

    page.should have_no_css("#person_notes")
    page.should have_no_content("This recruit sucks")
  end

  scenario "Filling out the form with invalid institution", :js => true do
    @program.thank_you_message = "This is a test"
    @program.notify_recruit_form_string = "hi@example.com, bye@example.com,"
    @program.save

    visit online_form_path(@program)

    fill_in 'person_first_name', :with => 'Phil'
    fill_in 'person_last_name', :with => 'Brabbs'
    fill_in 'person_nickname', :with => 'Dominator'
    fill_in 'person_address_attributes_street', :with => '123 Main St.'

    fill_in 'school', :with => 'Nonsense High School'
    click_button 'Send'
    accept_alert

    Recruit.where(:last_name => 'Brabbs').first.should be_nil
  end
end
