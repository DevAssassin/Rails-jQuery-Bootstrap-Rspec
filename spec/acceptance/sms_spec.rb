require 'acceptance/acceptance_helper'

feature "SMS Messaging", %q{
  In order to be able communicate with others on the system
  As a compliance officer
  I want to be able to send text messages to people and track them in my system
} do

  background do
    log_in

    # FIXME: Why doesn't this work in the fabricator?
    @account.allow_phonecalls = false
    @account.allow_sms = true
    @account.save

    #Interactions::Sms.stub!(:execute)
  end

  scenario "SMSing a single coach", :js => true do
    coach = Fabricate(:coach, :account => @account, :program => @program)

    visit person_path(coach)

    click_link "SMS"

    within('.interaction-form.new.sms') do
      fill_in "Phone number", :with => "734-846-3180"
      fill_in "Text", :with => "texting test"

      click_button "Save"
    end

    within('ul.interactions') do
      page.should have_content("734-846-3180")
      page.should have_content("texting test")
    end
  end

  scenario "Mass SMSing coaches", :js => true do
    coach1 = Fabricate(:coach, :account => @account, :cell_phone => "7348463180", :program => @program)
    coach2 = Fabricate(:coach, :account => @account, :cell_phone => "7349614759", :program => @program)

    visit coaches_path

    [coach1, coach2].each do |coach|
      within("#person-row-#{coach.id}") do
        check("people[]")
      end
    end

    within(".actions") do
      click_button "SMS"
    end

    fill_in :text, :with => "text message"

    click_button "Send"

    current_path.should == coaches_path

    [coach1, coach2].each do |coach|
      visit person_path(coach)
      page.should have_content("text message")
    end
  end
end
