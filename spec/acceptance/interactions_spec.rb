require 'acceptance/acceptance_helper'

feature "Interactions", %q{
  In order to log my interactions with a recruit
  As a coach
  I want to create, edit, and view interactions
} do

  background do
    log_in
  end

  context "on recruits" do
    let(:person) { Fabricate(:baseball_recruit, :program => @program) }
    subject { person_path(person) }
    let(:dashboard_page) { dashboard_path(@program) }

    it_behaves_like "comment interaction"
    it_behaves_like "phone call interaction"
  end

  # TODO test at program level too

  context "on coaches" do
    let(:person) { Fabricate(:coach, :account => @account, :program => @program) }
    subject { person_path(person) }
    let(:dashboard_page) { account_dashboard_path(@account) }

    it_behaves_like "comment interaction"
    it_behaves_like "phone call interaction"
  end

  context "on rostered players" do
    let(:person) { Fabricate(:rostered_player, :account => @account, :program => @program) }
    subject { person_path(person) }
    let(:dashboard_page) { account_dashboard_path(@account) }

    it_behaves_like "comment interaction"
    it_behaves_like "phone call interaction"
  end

  context "on other people" do
    let(:person) { Fabricate(:person, :account => @account, :program => @program) }
    subject { person_path(person) }
    let(:dashboard_page) { dashboard_path(@program) }

    it_behaves_like "comment interaction"
    it_behaves_like "phone call interaction"

    scenario "adding a donation interaction", :js => true do
      visit subject

      click_link "Log Donation"

      within('.interaction-form.new.donation') do
        fill_in 'Interaction time', :with => 4.months.ago
        fill_in 'Amount', :with => '$1000'
        fill_in 'Text', :with => 'Test Notes'

        click_button 'Save'
      end

      current_path.should == subject

      within('ul.interactions .interaction') do
        page.should have_content('Donation')
        page.should have_content('$1,000.00')
        page.should have_content('Test Notes')
        page.should have_content(4.months.ago.to_s.squish)
      end
    end
  end

  scenario "Phone call countable checkbox", :js => true do
    Account.any_instance.stub(:rules_engine?) { true }

    recruit = Fabricate(:baseball_recruit, :program => @program)

    visit person_path(recruit)

    click_link 'Phone call'

    within('.interaction-form.new.phone-call') do
      page.should have_checked_field('Countable')
      select 'Unreachable'
      page.should have_unchecked_field('Countable')
      select 'Completed', :from => 'Status'
      page.should have_checked_field('Countable')
    end
  end

  scenario "Phone call countable checkbox hidden without rules engine", :js => true do
    Account.any_instance.stub(:rules_engine?) { false }
    recruit = Fabricate(:baseball_recruit, :program => @program)

    visit person_path(recruit)

    click_link 'Phone call'

    within('.interaction-form.new.phone-call') do
      page.should_not have_field('Countable')
      select 'Completed', :from => 'Status'
      page.should_not have_field('Countable')
    end
  end

  scenario "Phone call countable checkbox not recruit", :js => true do
    Account.any_instance.stub(:rules_engine?) { true }

    person = Fabricate(:person, :program => @program)

    visit person_path(person)

    click_link 'Phone call'

    within('.interaction-form.new.phone-call') do
      page.should_not have_unchecked_field('Countable')
      select 'Completed', :from => 'Status'
      page.should_not have_checked_field('Countable')
    end
  end

  scenario "Adding a letter interaction", :js => true do
    recruit = Fabricate(:baseball_recruit, :program => @program)

    visit person_path(recruit)

    click_link 'Write Letter'
    within('.interaction-form.new.letter') do
      fill_in 'Interaction time', :with => 4.months.ago
      fill_in 'Subject', :with => 'Test Subject'
      fill_in 'Text', :with => 'Test Notes'

      click_button 'Save'
    end

    current_path.should == person_path(recruit)

    within('ul.interactions .interaction') do
      page.should have_content('Letter')
      page.should have_content('Test Subject')
      page.should have_content('Test Notes')
      page.should have_content(4.months.ago.to_s.squish)
    end
  end

  scenario "Editing a letter interaction", :js => true do
    recruit = Fabricate(:baseball_recruit, :program => @program)
    interaction = Fabricate(:letter_interaction, :person => recruit)

    visit person_path(recruit)

    make_visible ".interaction-widget .interaction .meta a"

    within("#interaction_#{interaction.id}") do
      click_link ('Edit')
    end

    within('.interaction-form.edit.letter') do
      fill_in 'Interaction time', :with => 4.months.ago
      fill_in 'Subject', :with => 'Test Subject'
      fill_in 'Text', :with => 'Test Notes'

      click_button 'Save'
    end

    within('ul.interactions') do
      page.should have_content('Letter')
      page.should have_content('Test Subject')
      page.should have_content('Test Notes')
      page.should have_content(4.months.ago.to_s.squish)
    end
  end

  scenario "Adding a visit interaction", :js => true do
    recruit = Fabricate(:baseball_recruit, :program => @program)

    visit person_path(recruit)

    click_link 'Visit'
    within('.interaction-form.new.visit') do
      fill_in 'Interaction time', :with => 4.months.ago
      fill_in 'Text', :with => 'Test Notes'
      select 'Official', :from => 'Visit type'

      click_button 'Save'
    end

    current_path.should == person_path(recruit)

    within('ul.interactions') do
      page.should have_content("Visit")
      page.should have_content('Official')
      page.should have_content(4.months.ago.to_s.squish)
    end
  end

  scenario "Editing a visit interaction", :js => true do
    recruit = Fabricate(:baseball_recruit, :program => @program)
    interaction = Fabricate(:visit_interaction, :person => recruit)

    visit person_path(recruit)

    make_visible ".interaction-widget .interaction .meta a"

    within("#interaction_#{interaction.id}") do
      click_link ('Edit')
    end

    within('.interaction-form.edit.visit') do
      fill_in 'Interaction time', :with => 4.months.ago
      fill_in 'Text', :with => 'Test Notes'
      select 'Unofficial', :from => 'Visit type'

      click_button 'Save'
    end

    current_path.should == person_path(recruit)

    within('ul.interactions') do
      page.should have_content("Visit")
      page.should have_content('Unofficial')
      page.should have_content(4.months.ago.to_s.squish)
    end
  end


  scenario "Adding a contact/eval interaction", :js => true do
    recruit = Fabricate(:baseball_recruit, :program => @program)

    visit person_path(recruit)

    click_link 'Contact/Eval'
    within('.interaction-form.new.contact') do
      fill_in 'Interaction time', :with => 4.months.ago
      fill_in 'Text', :with => 'Test Notes'
      fill_in 'Others present', :with => 'Sam'
      fill_in 'Location', :with => 'The Big House'
      fill_in 'Event', :with => 'Football Game'
      select 'Evaluation', :from => 'Contact type'

      click_button 'Save'
    end

    current_path.should == person_path(recruit)

    within('ul.interactions') do
      page.should have_content('Evaluation')
      page.should have_content(4.months.ago.to_s.squish)
      page.should have_content('Test Notes')
      page.should have_content('Sam')
      page.should have_content('The Big House')
      page.should have_content('Football Game')
    end
  end

  scenario "Editing a contact/eval interaction", :js => true do
    recruit = Fabricate(:baseball_recruit, :program => @program)
    interaction = Fabricate(:contact_interaction, :person => recruit)

    visit person_path(recruit)

    make_visible ".interaction-widget .interaction .meta a"

    within("#interaction_#{interaction.id}") do
      click_link ('Edit')
    end

    within('.interaction-form.edit.contact') do
      fill_in 'Interaction time', :with => 4.months.ago
      fill_in 'Text', :with => 'Test Notes'
      fill_in 'Others present', :with => 'Sam'
      fill_in 'Location', :with => 'The Big House'
      fill_in 'Event', :with => 'Football Game'
      select 'Evaluation', :from => 'Contact type'

      click_button 'Save'
    end

    current_path.should == person_path(recruit)

    within('ul.interactions') do
      page.should have_content('Evaluation')
      page.should have_content(4.months.ago.to_s.squish)
      page.should have_content('Test Notes')
      page.should have_content('Sam')
      page.should have_content('The Big House')
      page.should have_content('Football Game')
    end
  end

  scenario "Adding a rating interaction", :js => true do
    recruit = Fabricate(:baseball_recruit, :program => @program)

    visit person_path(recruit)

    page.find(:css, '.person-info .stars .ui-stars-star').click()
    within('.interaction-form.new.rating') do
      fill_in 'Text', :with => 'Test Notes'

      click_button 'Save'
    end

    current_path.should == person_path(recruit)

    within('ul.interactions') do
      page.should have_content('Test Notes')
    end
  end

  scenario "Editing a rating interaction", :js => true do
    recruit = Fabricate(:baseball_recruit, :program => @program)
    interaction = Fabricate(:rating_interaction, :person => recruit)

    visit person_path(recruit)

    make_visible ".interaction-widget .interaction .meta a"

    within("#interaction_#{interaction.id}") do
      click_link ('Edit')
    end

    within('.interaction-form.edit.rating') do
      fill_in 'Text', :with => 'Test Notes'

      click_button 'Save'
    end

    current_path.should == person_path(recruit)

    within('ul.interactions') do
      page.should have_content('Test Notes')
    end
  end

  scenario "Automatically adding a creation interaction" do
    create_recruit

    within('ul.interactions') do
      page.should have_content("Created")
    end
  end

  scenario "Automatically adding a deletion interaction when recruit deleted" do
    recruit = Fabricate(:baseball_recruit, :program => @program)

    visit person_path(recruit)
    click_link 'Delete'
    page.should have_content('Recruit was successfully deleted.')

    visit dashboard_path(@program)

    within('ul.interactions') do
      page.should have_content("Deleted")
    end
  end

  scenario "Placing a call to a recruit in violation of rules", :js => true do
    Account.any_instance.stub(:allow_phonecalls?) { true }
    User.any_instance.stub(:cell_phone_verified?) { true }
    RuleEngine.any_instance.stub(:can_interact?) { false }

    recruit = Fabricate(:baseball_recruit, :program => @program, :home_phone => '555-555-5555')

    visit person_path(recruit)
    click_link '555-555-5555'

    within '.interaction-form.new' do
      page.should have_content('Phone Call')
    end

    click_button 'Place a call using this number'

    within '.interaction-form.new' do
      page.should have_content('Place Call')
    end

    click_button 'Dial'

    page.should have_content('No more calls are allowed to this recruit at this time.')
  end
end
