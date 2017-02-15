require 'acceptance/acceptance_helper'

feature "Form Groups", %q{
  In order to assign and track form groups
  As a compliance officer
  I want to create form groups and have them filled out by people
} do

  background do
    log_in(:user => Fabricate(:user, :superuser => true))
    change_scope(@account)
    @form = Fabricate(:form, :account => @account)
    @other_form = Fabricate(:other_form, :account => @account)
    @third_form = Fabricate(:third_form, :account => @account)
  end

  def setup(options={})
    options = {:name => "A group", :account => @account, :forms => [@form, @other_form]}.merge(options)
    @form_group = Fabricate(:form_group, options)
    3.times do |i|
      instance_variable_set("@person#{i}", Fabricate(:person, :account => @account))
    end
  end

  scenario "Creating a form", :js => true do
    visit form_groups_path
    click_link "Create Form Group"

    fill_in 'form_group_name', :with => 'A new form group'
    fill_in 'form_group_description', :with => "This is a form group."

    page.check("form_group_form_ids-#{@form.id}")
    page.check("form_group_form_ids-#{@third_form.id}")

    # Would be great to test this, but it doesn't seem to work properly
    #form_group_description = page.find('#form_group_description')
    #form1 = page.find("#form-group-form-#{@form.id}")
    #form3 = page.find("#form-group-form-#{@third_form.id}")

    ## Any element located above the check boxes on the page
    #form3.drag_to form_group_description

    click_button 'Save'

    page.should have_content "A new form group"
    form_group = FormGroup.last
    form_group.forms.size.should == 2
    #form_group.forms_in_order.should == [@third_form, @form]
  end

  scenario "Assigning and filling out a form group", :js => true do
    setup
    visit form_group_path(@form_group)

    click_link "Assign Form"

    # Assign form 1 to person1
    fill_in "token-input-task_form_group_assignments_#{@form_group.forms.first.id}_assignee_ids_string", :with => @person0.first_name
    page.should have_content @person0.name
    find('li', :text => @person0.name).click

    # Assign form 1 to person2 also
    fill_in "token-input-task_form_group_assignments_#{@form_group.forms.first.id}_assignee_ids_string", :with => @person1.first_name
    page.should have_content @person1.name
    find('li', :text => @person1.name).click

    # Assign form 2 to person3
    fill_in "token-input-task_form_group_assignments_#{@form_group.forms.second.id}_assignee_ids_string", :with => @person2.first_name
    page.should have_content @person2.name
    find('li', :text => @person2.name).click

    fill_in 'task_name', :with => 'Some grouped task'
    fill_in 'task_description', :with => 'Fill this forms out biotch.'

    click_button 'Save'

    task = Task.first
    within "#task-#{task.id}" do
      page.should have_content 'Some grouped task'
      page.should have_content @person0.name
      page.should have_content @person1.name
      page.should have_content @person2.name
      page.should have_content @form.name
      page.should have_content @other_form.name
    end

    # As assignee, fill out form1
    visit form_complete_path(@form, :auth_token => @person0.authentication_token, :task_id => task.id)
    click_button 'confirm-person'
    fill_in 'completed_form_data[hi]', :with => 'hey there'
    fill_in 'completed_form_data[whats_up]', :with => 'nothing much'
    click_button 'Submit'

    completed_form0 = CompletedForm.last

    # As compliance officer, make sure task gets marked out
    # visit form_groups, click completed forms, and click 'View completed form'
    visit form_groups_path
    page.should have_table('form-group-list', :rows => [[@form_group.name, "2", "0"]])
    visit form_group_completed_forms_path(@form_group)
    page.should have_table('completed-form-list', :rows => [[@person0.name, "#{@form.name}, #{@other_form.name}", task.name]])
    within "#completed-form-row-#{completed_form0.assignment_id}" do
      click_link 'View completed form'
    end
    within_frame 'preview' do
      page.should have_content @person0.name
      page.should have_field 'completed_form_data[hi]', :with => 'hey there'
      page.should have_field 'completed_form_data[whats_up]', :with => 'nothing much'

      page.should have_content @person2.name
    end

    # As assignee 2, fill out form1
    visit form_complete_path(@form, :auth_token => @person1.authentication_token, :task_id => task.id)
    click_button 'confirm-person'
    fill_in 'completed_form_data[hi]', :with => 'yo g dog'
    fill_in 'completed_form_data[whats_up]', :with => 'the sky'
    click_button 'Submit'

    completed_form1 = CompletedForm.last

    # As compliance officer, make sure second task is marked out
    visit form_groups_path
    page.should have_table('form-group-list', :rows => [[@form_group.name, '2', '0']])
    visit form_group_completed_forms_path(@form_group)
    page.should have_table('completed-form-list', :rows => [[@person1.name, "#{@form.name}, #{@other_form.name}", task.name]])
    within "#completed-form-row-#{completed_form1.assignment_id}" do
      click_link 'View completed form'
    end
    within_frame 'preview' do
      page.should have_content @person1.name
      page.should have_field 'completed_form_data[hi]', :with => 'yo g dog'
      page.should have_field 'completed_form_data[whats_up]', :with => 'the sky'
    end

    # As coach, fill out form for assignee 1
    assignment0 = task.assignments.detect { |a| a.assignee_id == @person0.id }
    assignment0_2 = task.assignments.detect { |a| a.dependent_assignment_id == assignment0.id }
    visit form_complete_path(@other_form, :auth_token => @person2.authentication_token, :task_id => task.id, :assignment_id => assignment0_2.id)
    click_button 'confirm-person'
    # Coach should see the info that @person0 filled out
    within "#form" do
      page.should have_content @person0.name
      page.should have_field 'completed_form_data[hi]', :with => 'hey there'
      page.should have_field 'completed_form_data[whats_up]', :with => 'nothing much'
    end
    # Coach fills in second part of form
    fill_in 'completed_form_data[sign]', :with => 'signature here'
    fill_in 'completed_form_data[do_stuff]', :with => 'ok done'
    click_button 'Submit'

    # As compliance officer, login and view completed form 1
    visit form_groups_path
    page.should have_table('form-group-list', :rows => [[@form_group.name, "1", "1"]])
    within "#form-group-list" do
      click_link '1'
    end
    page.should have_table('completed-form-list', :rows => [["#{@person0.name}, #{@person2.name}", "#{@form.name}, #{@other_form.name}", task.name]])
    within "#completed-form-row-#{completed_form0.assignment_id}" do
      click_link 'View completed form'
    end
    within_frame 'preview' do
      page.should have_content @person0.name
      page.should have_field 'completed_form_data[hi]', :with => 'hey there'
      page.should have_field 'completed_form_data[whats_up]', :with => 'nothing much'

      page.should have_content @person2.name
      page.should have_field 'completed_form_data[sign]', :with => 'signature here'
      page.should have_field 'completed_form_data[do_stuff]', :with => 'ok done'
    end

    # Task should still not be complete
    visit tasks_path
    find('li.task', :text => 'Some grouped task')[:class].should_not include('completed')

    # As coach, fill out form for assignee 2
    assignment1 = task.assignments.detect { |a| a.assignee_id == @person1.id }
    assignment1_2 = task.assignments.detect { |a| a.assignee_id == @person2.id && a.dependent_assignment_id == assignment1.id }
    visit form_complete_path(@other_form, :auth_token => @person2.authentication_token, :task_id => task.id, :assignment_id => assignment1_2.id)
    click_button 'confirm-person'
    # Coach should see the info that @person0 filled out
    within "#form" do
      page.should have_content @person1.name
      page.should have_field 'completed_form_data[hi]', :with => 'yo g dog'
      page.should have_field 'completed_form_data[whats_up]', :with => 'the sky'
    end
    # Coach fills in second part of form
    fill_in 'completed_form_data[sign]', :with => 'me sign'
    fill_in 'completed_form_data[do_stuff]', :with => 'ok i did'
    click_button 'Submit'

    # As compliance officer, login and view completed form 2
    visit grouped_form_group_completed_forms_path(@form_group.id, assignment1.id)
    within_frame 'preview' do
      page.should have_content @person1.name
      page.should have_field 'completed_form_data[hi]', :with => 'yo g dog'
      page.should have_field 'completed_form_data[whats_up]', :with => 'the sky'

      page.should have_content @person2.name
      page.should have_field 'completed_form_data[sign]', :with => 'me sign'
      page.should have_field 'completed_form_data[do_stuff]', :with => 'ok i did'
    end

    # Task should now be marked complete
    visit tasks_path
    page.should have_no_content "Some grouped task"
    visit completed_tasks_path
    find('li.task', :text => 'Some grouped task')[:class].should include('completed')

    change_scope(@account)
    visit grouped_form_group_completed_forms_path(@form_group.id, assignment1.id)
    accept_js_confirm do
      click_link 'Delete'
    end
    visit form_groups_path
    page.should have_table('form-group-list', :rows => [[@form_group.name, "1", "1"]])
    visit tasks_path
    find('li.task', :text => 'Some grouped task')[:class].should_not include('completed')
  end

  scenario "Assigning and filling out a form group to only 1 person per form", :js => true do
    setup
    visit form_group_path(@form_group)

    click_link "Assign Form"

    # Assign form 1 to person1
    fill_in "token-input-task_form_group_assignments_#{@form_group.forms.first.id}_assignee_ids_string", :with => @person0.first_name
    page.should have_content @person0.name
    find('li', :text => @person0.name).click

    # Assign form 1 to person2 also
    fill_in "token-input-task_form_group_assignments_#{@form_group.forms.second.id}_assignee_ids_string", :with => @person1.first_name
    page.should have_content @person1.name
    find('li', :text => @person1.name).click

    fill_in 'task_name', :with => 'Some grouped task'
    fill_in 'task_description', :with => 'Fill this forms out biotch.'

    click_button 'Save'

    task = Task.last
    assignment0 = task.assignments.detect { |a| a.assignee_id == @person0.id }
    assignment1 = task.assignments.detect { |a| a.assignee_id == @person1.id }
    # First person fills it out
    visit form_complete_path(@form, :auth_token => @person0.authentication_token, :task_id => task.id)
    click_button 'confirm-person'
    fill_in 'completed_form_data[hi]', :with => 'hey there'
    fill_in 'completed_form_data[whats_up]', :with => 'nothing much'
    click_button 'Submit'

    # Second person fills it out
    visit form_complete_path(@other_form, :auth_token => @person1.authentication_token, :task_id => task.id, :assignment_id => assignment1.id)
    click_button 'confirm-person'
    # Coach should see the info that @person0 filled out
    within "#form" do
      page.should have_content @person0.name
      page.should have_field 'completed_form_data[hi]', :with => 'hey there'
      page.should have_field 'completed_form_data[whats_up]', :with => 'nothing much'
    end
    # Coach fills in second part of form
    fill_in 'completed_form_data[sign]', :with => 'signature here'
    fill_in 'completed_form_data[do_stuff]', :with => 'ok done'
    click_button 'Submit'

    # Compliance officer views entire completed form group
    visit grouped_form_group_completed_forms_path(@form_group.id, assignment0.id)
    within_frame 'preview' do
      page.should have_content @person0.name
      page.should have_field 'completed_form_data[hi]', :with => 'hey there'
      page.should have_field 'completed_form_data[whats_up]', :with => 'nothing much'

      page.should have_content @person1.name
      page.should have_field 'completed_form_data[sign]', :with => 'signature here'
      page.should have_field 'completed_form_data[do_stuff]', :with => 'ok done'
    end

    visit dashboard_path(@program)
    page.should have_selector('.interaction-list .task-completed', :text => 'Completed')
    page.should have_link("view completed form", :href => grouped_form_group_completed_forms_path(@form_group.id, assignment0.id))
  end
end
