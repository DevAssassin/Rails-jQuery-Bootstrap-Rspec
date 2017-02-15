require 'acceptance/acceptance_helper'

feature "Custom Fields" do

  background do
    log_in(:user => Fabricate(:user, :superuser => true))
  end

  scenario "Hidden fields" do
    visit program_edit_form_path(@program)
    @program.sport_class.hideable_fields.each do |field|
      uncheck "toggle_#{field}"
    end
    click_button 'Save'
    @program.reload.hidden_fields.should == @program.sport_class.hideable_fields
    visit new_recruit_path
    @program.sport_class.hideable_fields.each do |field|
      page.should_not have_css("#person_#{field}")
    end
  end

  scenario "Custom fields", :js => true do
    @program.custom_fields.create(:label => 'Test Field 1', :section => 'academic', :visible => true)
    @program.custom_fields.create(:label => 'Delete Me', :section => 'personal', :visible => true)
    visit program_edit_form_path(@program)

    first = all('.custom_field')[0]
    first.click_link 'Rename'
    first.find('input[type="text"]').set('First Test Field')
    all('.custom_field')[1].click_link 'Delete'
    accept_alert

    click_link 'Add a field'
    third = find('.custom_field.new')
    third.find('input[type="text"]').set('Test Field 2')
    third.find('select').set('athletic')

    click_button 'Save'
    visit new_recruit_path
    fill_in 'person_first_name', :with => 'Recruit'
    fill_in 'person_last_name', :with => 'SmithBob'
    fill_in 'First Test Field', :with => 'Custom field value'
    fill_in 'Test Field 2', :with => 'Another field value'
    page.should have_no_content('Test Field 1')
    page.should have_no_content('Delete Me')
    click_button 'Save'
    page.should have_content('Custom field value')
    page.should have_content('Another field value')
  end
end
