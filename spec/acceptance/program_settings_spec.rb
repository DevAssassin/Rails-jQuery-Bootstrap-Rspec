require 'acceptance/acceptance_helper'

feature "Changing program settings" do
  background do
    log_in
  end

  it "allows customization of the program name" do
    visit edit_program_path(@program)

    within("form.program") do
      fill_in :program_name, with: "testprogram"

      click_button("Save")
    end

    within("#header") do
      page.should have_content("testprogram")
    end
  end
end
