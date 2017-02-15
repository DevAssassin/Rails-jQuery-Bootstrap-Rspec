require 'acceptance/acceptance_helper'

feature "Recruit Boards", %q{
  In order to keep track of my best recruits
  As a coach
  I want to manage recruit boards that I can reorder
} do

  background do
    log_in
  end

  scenario "Visiting the default board" do
    visit program_recruit_boards_path(@program)

    page.should have_content "Default Recruit Board"
  end

  scenario "Creating a new board" do
    visit program_recruit_boards_path(@program)

    within '.new-row' do
      fill_in "recruit_board_name", :with => "New Board"
      click_button 'Save'
    end

    page.should have_content "New Board"
  end

  scenario "Editing a board's name" do
    visit program_recruit_boards_path(@program)

    within '.edit-row' do
      fill_in "recruit_board_name", :with => "Edited Board"
      click_button 'Save'
    end

    page.should have_content "Edited Board"
  end

  scenario "Setting default recruit boards", :js => true do
    recruit = Fabricate(:baseball_recruit, :program => @program)
    Fabricate(:recruit_board, :program => @program) # Default board
    board = Fabricate(:recruit_board, :program => @program, :name => "Another Recruit Board")

    visit program_recruit_board_path(@program,board)

    within '#sidebar' do
      check 'Make Default'
    end

    visit dashboard_path(@program)

    within '.recruit-boards .recruit-board:first' do
      page.should have_content board.name
    end
  end

  scenario "Showing recruit boards on dashboard", :js => true do
    recruit = Fabricate(:baseball_recruit, :program => @program)
    board1 = Fabricate(:recruit_board, :program => @program) # Default board
    board2 = Fabricate(:recruit_board, :program => @program, :name => "Another Recruit Board")
    board3 = Fabricate(:recruit_board, :program => @program, :name => "A Third Recruit Board")

    visit program_recruit_board_path(@program,board2)
    within '#sidebar' do
      check 'Show on Dashboard'
    end

    visit program_recruit_board_path(@program,board3)

    within '#sidebar' do
      check 'Make Default'
    end

    visit program_recruit_board_path(@program,board1)

    within '#sidebar' do
      uncheck 'Show on Dashboard'
    end

    visit dashboard_path(@program)

    within '.recruit-boards' do
      within '.recruit-board:first' do
        page.should have_content board3.name
      end
      page.should have_content board2.name
      page.should_not have_content board1.name
    end
  end

  scenario "Adding a recruit to a board from the recruit page" do
    recruit = Fabricate(:baseball_recruit, :program => @program)
    board = Fabricate(:recruit_board, :program => @program)

    visit person_path(recruit)

    within('.boards-form') do
      check("board_id_#{board.id}")
      click_button("Save")
    end

    current_path.should == person_path(recruit)

    find("#board_id_#{board.id}").should be_checked
  end

  scenario "Adding a recruit to a board should show board checked when editing recruit" do
    recruit = Fabricate(:baseball_recruit, :program => @program)
    board = Fabricate(:recruit_board, :program => @program)

    visit person_path(recruit)

    within('.boards-form') do
      check("board_id_#{board.id}")
      click_button("Save")
    end

    visit edit_person_path(recruit)

    find("#recruit_board_ids_#{board.id}").should be_checked
  end

  scenario "Assigning a recruit from the recruit creation page" do
    board = Fabricate(:recruit_board, :program => @program)

    create_recruit do
      check "recruit_board_ids_#{board.id}"
    end

    find("#board_id_#{board.id}").should be_checked
  end

  scenario "Deleting a recruit should remove him from his board" do
    recruit = Fabricate(:baseball_recruit, :program => @program)
    board = Fabricate(:recruit_board, :program => @program)

    visit person_path(recruit)
    within('.boards-form') do
      check("board_id_#{board.id}")
      click_button("Save")
    end

    visit program_recruit_board_path(@program, board)
    page.should have_content(recruit.first_name)

    visit person_path(recruit)
    click_link 'Delete'
    page.has_content?('Recruit was successfully deleted.')

    visit program_recruit_board_path(@program, board)
    page.should have_content "MyString"
    page.should_not have_content(recruit.first_name)
  end
end
