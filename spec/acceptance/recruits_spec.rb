require 'acceptance/acceptance_helper'

feature "Recruits", %q{
  In order to track my recruits
  As a coach
  I want to be able to add and manage my recruits
} do

  background do
    log_in
  end

  context "from a program" do
    scenario "Creating a recruit manually" do
      create_recruit

      page.should have_content("Phil")
      page.should have_content("Brabbs")
      page.should have_content("Dominator")
      page.should have_content("123 Main")
    end

    scenario "Viewing a recruit in the table", :js => true do
      recruit = Fabricate(:baseball_recruit, :last_name => 'Brabbs', :program => @program)

      visit recruits_path

      page.should have_content("Brabbs")
    end

    scenario "Viewing only my recruits", :js => true do
      my_recruit = Fabricate(:baseball_recruit, :last_name => 'Mine', :program => @program)
      not_my_recruit = Fabricate(:baseball_recruit, :last_name => 'NotMine', :program => @program)
      @user.default_only_my_contacts = true
      @user.save
      my_recruit.add_watchers([@user])
      my_recruit.save
      my_recruit.watchers.should include @user
      not_my_recruit.watchers.should_not include @user

      visit person_path(my_recruit)
      click_link 'Contacts'

      page.should have_content("Mine")
      page.should_not have_content("NotMine")
    end

    scenario "Editing a recruit" do
      recruit = Fabricate(:baseball_recruit, :program => @program)

      visit edit_person_path(recruit)

      fill_in 'person_nickname', :with => 'Rhino'
      click_button 'Save'

      page.should have_content("Rhino")
      page.should_not have_content("Dominator")
    end

    scenario "Editing a recruit should allow adding to recruit board" do
      @user.program = @program
      @user.recruit_board #create a recruit board

      recruit = Fabricate(:baseball_recruit, :program => @program)

      visit edit_person_path(recruit)

      within('.inputs') do
        check("Default Recruit Board")
      end

      fill_in 'person_first_name', :with => 'Boardy'
      click_button 'Save'

      visit program_recruit_boards_path(@program)
      page.should have_content('Boardy')
    end

    scenario "Editing a recruit's profile picture" do
      recruit = Fabricate(:baseball_recruit, :program => @program)

      visit edit_person_path(recruit)

      attach_file(:photo, "#{Rails.root}/app/assets/images/test_photo.png")
      click_button 'Save'
    end

    scenario "Removing a recruit's profile picture", :js => true do
      recruit = Fabricate(:baseball_recruit, :program => @program)

      visit edit_person_path(recruit)

      attach_file(:photo, "#{Rails.root}/app/assets/images/test_photo.png")
      click_button 'Save'

      visit edit_person_path(recruit)

      check ('person_remove_photo')
      click_button 'Save'
    end

    scenario "Deleting a recruit" do
      recruit = Fabricate(:baseball_recruit, :program => @program)

      visit person_path(recruit)
      click_link 'Delete'
      visit recruits_path

      page.has_content?('Recruit was successfully deleted.')
      page.should_not have_content("Phil")
    end

    scenario "Mass deleting a recruit", :js => true do
      leo = Fabricate(:baseball_recruit, :program => @program)
      sam = Fabricate(:baseball_recruit, :program => @program)
      recruits = [leo, sam]

      visit recruits_path

      recruits.each do |recruit|
        within("#person-row-#{recruit.id}") do
          check("people[]")
        end
      end

      within ('.actions') do
        accept_js_confirm do
          click_button 'Delete'
        end
      end

      page.should_not have_content(sam.last_name)
    end

    scenario "Restoring a recruit" do
      recruit = Fabricate(:baseball_recruit, :program => @program)

      visit person_path(recruit)
      click_link 'Delete'

      visit person_path(recruit)
      click_link 'Restore'
      page.should have_content(recruit.name)
    end

    scenario "Recruit not added to board if recruit is not saved" do
      @user.program = @program
      @user.recruit_board #create a recruit board

      visit new_recruit_path

      within('.inputs') do
        check("Default Recruit Board")
      end

      fill_in 'person_first_name', :with => 'Phil'
      click_button 'Save'

      visit program_recruit_boards_path(@program)
      page.should_not have_content('Phil')
    end

    scenario "Setting the country and states for a recruit", :js => true do
      recruit = Fabricate(:baseball_recruit, :program => @program)

      visit edit_person_path(recruit)

      select('Canada', :from => 'person_address_attributes_country')
      #page.should have_xpath("//select[@id = 'person_address_attributes_state']/option[text() = 'Canada-State 2']")
      select('Canada-State 2', :from => 'person_address_attributes_state')
      click_button 'Save'

      visit person_path(recruit)

      within('.country-name') do
        page.should have_content("Canada")
      end
      within('.region') do
        page.should have_content("Canada-State 2")
      end
    end

    scenario "Inviting recruit to fill in profile", :js => true do
      recruit = Fabricate(:baseball_recruit, :program => @program)
      recruit = Recruit.first

      visit person_path(recruit)

      click_link 'Invite Recruit'

      current_path.should == new_email_path
      page.should have_content "<#{recruit.email}>"
      within '#email_body' do
        page.should have_content '{{{invite_link}}}'
      end
    end

    scenario "Mass-inviting existing recruits", :js => true do
      leo = Fabricate(:baseball_recruit, :program => @program, :email => 'leo@example.com')
      sam = Fabricate(:baseball_recruit, :program => @program, :email => 'sam@example.com')
      recruits = [leo, sam]

      visit recruits_path

      recruits.each do |recruit|
        within("#person-row-#{recruit.id}") do
          check("people[]")
        end
      end

      within ('.actions') do
        click_button 'Invite'
      end

      current_path.should == new_email_path
      page.should have_content '<leo@example.com>'
      page.should have_content '<sam@example.com>'
      within('#email_body') do
        page.should have_content '{{{invite_link}}}'
      end
    end

    scenario "Mass-inviting new recruits", :js => true do
      visit mass_new_people_path

      fill_in 'person_emails', :with => "1@example.com\n2@example.com, 3@example.com"

      click_button 'Next Step'

      current_path.should == new_email_path

      page.should have_content '<1@example.com>'
      page.should have_content '<2@example.com>'
      page.should have_content '<3@example.com>'

      within('#email_body') do
        page.should have_content '{{{invite_link}}}'
      end
    end

    scenario "Searching for a specific recruit", :js => true do
      recruit = Fabricate(:recruit, :program => @program, :first_name => "TestRecruit123", :last_name => "Smith")

      within ("#global-search-box") do
        fill_in "global_search", :with => "TestRecruit123"
      end

      within ("ul.ui-autocomplete") do
        find("a").click
      end

      current_path.should == person_path(recruit)
    end

    scenario "Changing recruit to rostered player to alumnus" do
      recruit = Fabricate(:baseball_recruit, :program => @program)
      recruit.gpa = '3.5'
      recruit.save

      visit person_path(recruit)

      within(".actions") do
        select('Rostered Player', :from => 'person_conversion_type')
        click_on 'Perform Conversion'
      end

      RosteredPlayer.last._id.should == recruit._id
      RosteredPlayer.last.gpa.should == '3.5' #Recruit fields should still be there

      visit person_path(recruit)

      within(".actions") do
        select('Alumnus', :from => 'person_conversion_type')
        click_on 'Perform Conversion'
      end

      Person.alumni.last._id.should == recruit._id

      visit person_path(recruit)

      within(".actions") do
        select('Recruit', :from => 'person_conversion_type')
        click_on 'Perform Conversion'
      end

      Recruit.last._id.should == recruit._id
      Recruit.last._type.should == recruit._type
    end

    scenario "Changing recruit on a board to alumnus" do
      recruit = Fabricate(:baseball_recruit, :program => @program)
      board = Fabricate(:recruit_board, :program => @program)

      visit person_path(recruit)

      within('.boards-form') do
        check("board_id_#{board.id}")
        click_button("Save")
      end

      visit program_recruit_board_path(@program, board)
      page.should have_content recruit.first_name

      visit person_path(recruit)

      within(".actions") do
        select('Alumnus', :from => 'person_conversion_type')
        click_on 'Perform Conversion'
      end

      visit program_recruit_board_path(@program, board)
      page.should have_content board.name
      page.should_not have_content recruit.first_name #this also makes sure it doesn't just plain break
    end

  end

  context "from an account" do

    before(:each) do
      change_scope(@account)
    end

    it "can create from the list of programs" do
      visit new_recruit_path

      click_link @program.name

      fill_in 'person_first_name', :with => 'Phil'
      fill_in 'person_last_name', :with => 'Brabbs'
      fill_in 'person_nickname', :with => 'Dominator'
      fill_in 'person_address_attributes_street', :with => '123 Main St.'
      fill_in 'person_email', :with => 'phil@example.com'

      click_button 'Save'

      page.should have_content("Phil")
      page.should have_content("Brabbs")
      page.should have_content("Dominator")
      page.should have_content("123 Main")
    end
  end

  context "permissions" do

    # TODO: Figure out why this doesn't pass
    pending "shows sms button when user can sms recruits" do
      @account.can_sms_recruits = true
      visit people_path(:type => 'recruits')

      within('#mass-actions') do
        page.should have_content('SMS')
      end
    end

  end

  scenario "profile header bubbles", :js => true do
    watcher1 = Fabricate(:user, :first_name => 'Watcher1', :programs => [@program])
    watcher2 = Fabricate(:user, :first_name => 'Watcher2', :programs => [@program])
    recruit = Fabricate(:baseball_recruit, :program => @program, :program_tags => 'Tag1', :watchers => [watcher1])
    recruit.program.account.update_attribute(:profile_bubbles,true)
    board1 = Fabricate(:recruit_board, :name => 'Board 1', :program => @program, :recruit_ids => [recruit.id])
    board2 = Fabricate(:recruit_board, :name => 'Board 2', :program => @program)

    visit person_path(recruit)

    # Status specs
    within('.bubble.status') do
      page.should have_content('New')
      page.find('.update-status-link').click
    end
    within('.update-status') do
      select 'Offered', :from => 'Update status'
      click_button 'Save'
    end
    within('.bubble.status') do
      page.should have_content('Offered')
    end

    # Tag specs
    within('.bubble-section.tags') do
      page.should have_content 'Tag1'
      find('.bubble-delete').click
      page.should have_no_content 'Tag1'
      recruit.reload.program_tags.should_not include('Tag1')
    end
    find('.add-tag-link').click
    within '.new-tag' do
      find('.bubble-input').set('Tag2')
      click_button 'Save'
    end
    within('.bubble-section.tags') do
      page.should have_content 'Tag2'
      recruit.reload.program_tags.should include('Tag2')
      find('.bubble-delete').click
      page.should_not have_content 'Tag2'
      recruit.reload.program_tags.should_not include('Tag2')
    end

    # Watcher specs
    within('.bubble-section.watchers') do
      page.should have_content watcher1.name
      find('.bubble-delete').click
      page.should have_no_content watcher1.name
      recruit.reload.watchers.should_not include(watcher1)
    end
    find('.assign-watcher-link').click
    within '.assign-watcher' do
      find('.chzn-single').click
      find('.chzn-search input').set(watcher2.name)
      find('.chzn-results .active-result').click
      click_button 'Save'
    end
    within('.bubble-section.watchers') do
      page.should have_content watcher2.name
      recruit.reload.watchers.should include(watcher2)
      find('.bubble-delete').click
      page.should_not have_content watcher2.name
      recruit.reload.watchers.should_not include(watcher2)
    end

    # Board specs
    within('.bubble-section.recruit-boards') do
      page.should have_content board1.name
      find('.bubble-delete').click
      page.should have_no_content board1.name
      recruit.reload.recruit_boards.should_not include(board1)
    end
    find('.assign-board-link').click
    within '.assign-board' do
      find('.chzn-single').click
      find('.chzn-search input').set(board2.name)
      find('.chzn-results .active-result').click
      click_button 'Save'
    end
    within('.bubble-section.recruit-boards') do
      page.should have_content board2.name
      recruit.reload.recruit_boards.should include(board2)
      find('.bubble-delete').click
      page.should_not have_content board2.name
      recruit.reload.recruit_boards.should_not include(board2)
    end

  end

end
