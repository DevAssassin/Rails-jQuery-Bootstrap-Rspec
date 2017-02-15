require 'acceptance/acceptance_helper'

feature "Roster Tab", %q{
  In order to streamline my compliance process
  As a compliance officer
  I want to be able to interact with players at my institution
} do

  background do
    log_in
    change_scope(@account)
  end

  scenario "Creating a player manually" do
    create_rostered_player

    page.should have_content("Dernard")
    page.should have_content("Robinson")
  end

  scenario "Viewing a player in the table", :js => true do
    player = Fabricate(:rostered_player, :account => @account)

    visit rostered_players_path

    page.should have_content(player.first_name)
  end

end
