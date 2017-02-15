shared_examples_for "Recruit" do
  it "has printable profile with recruit's name" do
    recruit = @program.sport_class.create(:first_name => "Recruit", :last_name => "Smith", :program => @program)

    visit person_path(recruit)
    click_link 'Print'

    page.should have_content(recruit.name)
  end
end

shared_examples_for "comment interaction" do
  scenario "Adding a comment interaction", :js => true do
    visit subject

    click_link 'Comment'
    within('.interaction-form.new.comment') do
      fill_in 'Text', :with => 'Test Notes'

      click_button 'Save'
    end

    within('ul.interactions') do
      page.should have_content('Comment')
      page.should have_content('Test Notes')
    end
  end

  scenario "Editing a comment interaction", :js => true do
    interaction = Fabricate(:comment_interaction, :person => person)

    visit subject

    make_visible ".interaction-widget .interaction .meta a"

    within("#interaction_#{interaction.id}") do
      click_link ('Edit')
    end

    within('.interaction-form.edit.comment') do
      fill_in 'Text', :with => 'Test Notes'

      click_button 'Save'
    end

    within('ul.interactions') do
      page.should have_content('Comment')
      page.should have_content('Test Notes')
    end
  end

  scenario "Comment interactions logged on the dashboard", :js => true do
    visit subject

    click_link 'Comment'
    within('.interaction-form.new.comment') do
      fill_in 'Text', :with => 'Test Notes'

      click_button 'Save'
    end

    within('ul.interactions') do
      page.should have_content('Comment')
    end

    visit dashboard_page

    within('ul.interactions') do
      page.should have_content('Comment')
      page.should have_content('Test Notes')
    end
  end
end

shared_examples_for "phone call interaction" do
  scenario "Adding a phone call interaction", :js => true do
    visit subject

    click_link 'Phone call'

    within('.interaction-form.new.phone-call') do
      fill_in 'Text', :with => 'Test Notes'
      fill_in 'Phone number', :with => '7345551212'
      fill_in 'Duration', :with => '1:20:05'
      select 'Completed', :from => 'Status'

      click_button 'Save'
    end

    within('ul.interactions') do
      page.should have_content("Phone Call")
      page.should have_content('Test Notes')
      page.should have_content('734-555-1212')
      page.should have_content('Completed')
      page.should have_content('1h 20m 5s')
    end
  end

  #scenario "Failure adding a phone call interaction", :js => true do
  #  visit subject

  #  click_link 'Phone call'

  #  within('.interaction-form.new.phone-call') do
  #    fill_in 'Text', :with => 'Test Notes'
  #    fill_in 'Phone number', :with => '7345551212'
  #    select 'Completed', :from => 'Status'

  #    click_button 'Save'
  #  end

  #  within('.interaction-widget') do
  #    page.should have_content("can't be blank")
  #  end
  #end

  scenario "Editing a phone call interaction", :js => true do
    interaction = Fabricate(:phone_call_interaction, :person => person)

    visit subject

    make_visible ".interaction-widget .interaction .meta a"

    within("#interaction_#{interaction.id}") do
      click_link ('Edit')
    end

    within('.interaction-form.edit.phone-call') do
      fill_in 'Text', :with => 'Test Notes'
      fill_in 'Phone number', :with => '7345551212'
      fill_in 'Duration', :with => '1:20:05'
      select 'Completed', :from => 'Status'

      click_button 'Save'
    end

    within('ul.interactions') do
      page.should have_content("Phone Call")
      page.should have_content('Test Notes')
      page.should have_content('734-555-1212')
      page.should have_content('Completed')
      page.should have_content('1h 20m 5s')
    end
  end
end

shared_examples_for "program_taggable" do
  scenario "tagging a person from the person's profile" do
    visit subject

    within('.tags-form') do
      fill_in 'person_program_tags', :with => 'foo, bar, baz'
      click_button 'Save'
    end

    current_path.should == person_path(person)

    within('.person-header .tags') do
      page.should have_content('foo')
      page.should have_content('bar')
      page.should have_content('baz')
    end
  end

  scenario "tagging a person from the list", :js => true do

    people = [person, person2]

    visit list_page

    people.each do |person|
      within("#person-row-#{person.id}") do
        check("people[]")
      end
    end

    click_button 'Tag'
    fill_in 'multi-tag', :with => 'foo, bar, baz'
    click_button 'Add tags'

    current_path.should == list_page

    people.each do |person|
      visit person_path(person)

      within('.person-header .tags') do
        page.should have_content('foo')
        page.should have_content('bar')
        page.should have_content('baz')
      end
    end
  end
end
