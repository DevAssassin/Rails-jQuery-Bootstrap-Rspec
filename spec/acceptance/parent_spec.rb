require 'acceptance/acceptance_helper'

feature "Parents", %q{
  In order to track recruits' parents
  As a coach
  I want to be able to add and manage parents
} do

  background do
    log_in
  end

  scenario "adding children", :js => true do
    @parent = Fabricate(:person, :program => @program, :parent => true)
    @child = Fabricate(:baseball_recruit, :program => @program, :address => {:city => "Ann Arbor", :state => "MI"})

    visit edit_person_path(@parent)

    within ("form#person_edit") do
      check "person_parent"
      fill_in "child", :with => @child.last_name
    end

    within("ul.ui-autocomplete li") do
      page.should have_content("Ann Arbor, MI")
      find("a").click
    end

    find('#person_children_ids_string').value.split(/,\s?/).should include(@child.id.to_s)

    click_button 'Save'

    current_path.should == person_path(@parent)
    page.should have_content @child.last_name
  end

  scenario "adding existing child", :js => true do
    @parent = Fabricate(:person, :program => @program, :parent => true)
    @child1 = Fabricate(:baseball_recruit, :first_name => "William", :program => @program)
    @child2 = Fabricate(:baseball_recruit, :first_name => "Will", :program => @program)
    @parent.children_ids = [@child1.id]
    @parent.save

    visit edit_person_path(@parent)

    within ("form#person_edit") do
      check "person_parent"
      fill_in "child", :with => @child2.first_name
    end

    within("ul.ui-autocomplete li") do
      page.should have_no_content(@child1.last_name)
      page.should have_content(@child2.last_name)
    end
  end

  scenario "removing children", :js => true do
    @parent = Fabricate(:person, :program => @program, :parent => true)
    @child1 = Fabricate(:baseball_recruit, :program => @program)
    @child2 = Fabricate(:baseball_recruit, :program => @program)
    @parent.children_ids = [@child1.id, @child2.id]
    @parent.save

    visit edit_person_path(@parent)

    within(".children .child:first-child") do
      click_link 'Remove'
    end

    ids = find('#person_children_ids_string').value.split(/,\s?/)
    ids.should_not include(@child1.id.to_s)
    ids.should include(@child2.id.to_s)

    click_button 'Save'

    page.should have_no_content @child1.last_name
    page.should have_content @child2.last_name
  end

end
