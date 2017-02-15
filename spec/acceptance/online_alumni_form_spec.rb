require 'acceptance/acceptance_helper'

feature "Online form", %q{
  In order to have alumni added to my program through public url
  As a coach
  I want to have an online alumnus form for adding alumni
} do

  background do
    @account = Fabricate(:account)
    @program = Fabricate(:program, :account => @account)
    Fabricate(:country, :name => "United States of America")
    Fabricate(:country, :name => "Canada")
  end

  scenario "Filling out the form with valid data" do
    @program.alumni_thank_you_message = "Thanks alumnus"
    @program.notify_recruit_form_string = "hi@example.com, bye@example.com,"
    @program.save

    visit online_form_path(@program, :type => 'Alumnus')
    page.should have_content 'Online Alumnus Form'

    fill_in 'person_first_name', :with => 'Phil'
    fill_in 'person_last_name', :with => 'Brabbs'
    fill_in 'person_address_attributes_street', :with => '123 Main St.'
    fill_in 'person_email', :with => 'testme@test.com'

    lambda {
      click_button 'Send'
    }.should change(ActionMailer::Base.deliveries, :count).by(3)
    ActionMailer::Base.deliveries[-2].to.should == [ "bye@example.com" ]
    ActionMailer::Base.deliveries[-2].subject.should =~ /created a profile/

    alumnus = @program.alumni.first

    alumnus.first_name.should == 'Phil'
    alumnus.last_name.should == 'Brabbs'
    alumnus.class.should == Person
    page.should have_content("Thanks alumnus")
  end

  scenario "Updating profile with valid data" do
    alumnus = Fabricate(:alumnus, :program => @program, :account => @account, :email => 'testme@test.com')
    @program.alumni_thank_you_message = "Testing"
    @program.notify_recruit_form_string = "hi@example.com, bye@example.com,"
    @program.save

    visit invited_person_path(alumnus.authentication_token)

    fill_in 'person_first_name', :with => 'Steve'
    fill_in 'person_last_name', :with => 'McDudersauce'

    lambda {
      click_button 'Send'
    }.should change(ActionMailer::Base.deliveries, :count).by(3)
    ActionMailer::Base.deliveries[-2].to.should == [ "bye@example.com" ]
    ActionMailer::Base.deliveries[-2].subject.should =~ /updated their profile/

    alumnus = @program.alumni.first
    alumnus.first_name.should == 'Steve'
    alumnus.last_name.should == 'McDudersauce'
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

  scenario "Filling out online form" do
    visit online_form_path(@program)
    page.should have_no_css("#person_notes")
  end

  scenario "Updating profile with private notes" do
    alumnus = Fabricate(:alumnus, :program => @program, :notes => "This alumnus sucks")
    visit invited_person_path(alumnus.authentication_token)

    page.should have_no_css("#person_notes")
    page.should have_no_content("This alumnus sucks")
  end
end
