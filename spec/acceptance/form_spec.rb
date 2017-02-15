require 'acceptance/acceptance_helper'

feature "Forms", %q{
  In order to assign and track forms
  As a coach
  I want to create forms and have them filled out by contacts
} do

  background do
    log_in(:user => Fabricate(:user, :superuser => true))
  end

  def setup(form_options={})
    form_options = {:name => 'Some form', :account => @account}.merge(form_options)
    @form = Fabricate(:form, form_options)
  end

  def complete_form(path_options={})
    log_out
    if path_options[:auth_token]
      visit form_complete_path(@form, path_options)
      # landing page, confirm person
      page.should have_content('confirm that you are')
      click_button('confirm-person')
    else
      visit form_complete_path(@form, path_options)
      page.should have_field('submitter_name')

      # Try without filling in name
      click_button('confirm-person')
      page.should have_field('submitter_name')

      # Now fill in name this time
      fill_in 'submitter_name', :with => 'Steve Schwartz'
      click_button('confirm-person')

      page.should have_xpath("//input[@type='hidden'][@name='submitter_name'][@value='Steve Schwartz']")
    end

    page.should have_content(@form.name)

    fill_in 'completed_form_data[hi]', :with => "What's up?"
    fill_in 'completed_form_data[whats_up]', :with => "Not a whole lot."
    select 'Arizona', :from => 'completed_form_data[pick_one][again]'
    check('mood-happy')
    check('mood-funtime')
    choose 'hey-now'

    click_button 'Submit'
  end

  scenario "Creating a form", :js => true do
    visit form_groups_path

    click_link "Create Form Section"

    fill_in 'form_name', :with => "Some form"
    fill_in 'form_html', :with => Fabricate.attributes_for(:form)[:html]

    click_button 'Save'

    within_frame('preview') do
      page.should have_content('Some form')
    end
  end

  scenario "Editing a form", :js => true do
    setup
    visit forms_path

    click_link 'Some form'
    click_link 'Edit'

    fill_in 'form_name', :with => 'Some other form'
    fill_in 'form_html', :with => @form.html + "<input type='text' name='woot' />"

    click_button "Save"

    within_frame('preview') do
      page.should have_content('Some other form')
    end
  end

  scenario "Deleting a form", :js => true do
    setup
    visit forms_path

    click_link 'Some form'
    accept_js_confirm do
      click_link 'Delete'
    end

    current_path.should == forms_path
    page.should have_no_content @form.name
  end

  scenario "Trying to delete an undeletable form", :js => true do
    setup
    task = Fabricate(:task, :account => @account, :form => @form)
    @form.should_not be_deletable
    visit form_path(@form)

    page.should have_no_link 'Delete'
  end

  # TODO: maybe break this into smaller tests per functionality,
  # using fabricators to setup data where appropriate
  scenario "Completing a public form", :js => true do
    setup(:public => true)
    change_scope(@account)
    visit forms_path
    # Should have table with...                    Name        completed
    page.should have_table('form-list', :rows => [[@form.name, '0']])

    # As a person
    complete_form
    page.should have_content ('Thank you')

    # As a coach
    log_in(:program => @program)
    change_scope(@account)

    # Form-specific completed_forms path
    visit forms_path
    # Forms page should have table with...         Name        completed
    page.should have_table('form-list', :rows => [[@form.name, '1']])
    within '#form-list' do
      click_link '1'
    end
    # Completed forms page should have table with...         Name
    page.should have_table('completed-form-list', :rows => [[@form.name, 'Steve Schwartz']])
    within '#completed-form-list' do
      click_link 'View completed form'
    end

    within_frame 'preview' do
      page.should have_content('Steve Schwartz')

      # Completed form data, as filled in by person
      # input
      page.should have_field('completed_form_data[hi]', :with => "What's up?")
      # textarea
      page.should have_field('completed_form_data[whats_up]', :with => 'Not a whole lot.')
      # select
      page.should have_select('completed_form_data[pick_one][again]', :selected => 'Arizona')

      # checkbox group
      page.should have_checked_field('mood-happy')
      page.should have_checked_field('mood-funtime')
      page.should have_unchecked_field('mood-sad')

      # radio group
      page.should have_unchecked_field('hey-there')
      page.should have_checked_field('hey-now')
    end
  end

  scenario "Completing a private form as an assigned person completes correct task", :js => true do
    setup(:public => false)
    person = Fabricate(:person, :account => @account)
    other_person = Fabricate(:person, :account => @account)

    form_group = FormGroup.standalone_for(@form).first

    other_task = Fabricate(:task_with_form_group,
                           :account => @account,
                           :form_group => form_group,
                           :assignments => [Assignment.new(:assignee => other_person, :form => @form)])

    task = Fabricate(:task_with_form_group,
                     :account => @account,
                     :form_group => form_group,
                     :assignments => [Assignment.new(:assignee => person, :form => @form)])

    second_task = Fabricate(:task_with_form_group,
                            :account => @account,
                            :form_group => form_group,
                            :assignments => [Assignment.new(:assignee => person, :form => @form)])

    change_scope(@account)
    visit form_groups_path
    # Should have table with...                    Name        pending completed
    page.should have_table('form-group-list', :rows => [[@form.name, '3',    '0']])

    # As assigned person
    complete_form(:auth_token => person.authentication_token, :task_id => second_task.id)
    completed_form = CompletedForm.first
    completed_form.task.should == second_task
    second_task.reload.should be_complete
    second_task.completed_by?(person).should be_true

    # Should not allow assigned person to re-view and submit form
    visit form_complete_path(@form, :auth_token => person.authentication_token, :task_id => second_task.id)
    # landing page, confirm person
    page.should have_content('confirm that you are')
    click_button('confirm-person')
    page.should have_content 'already completed'

    # As coach
    log_in(:program => @program)
    change_scope(@account)

    visit form_groups_path
    # Should have table with...                    Name        pending completed
    page.should have_table('form-group-list', :rows => [[@form.name, '2',    '1']])
    visit form_completed_form_path(@form, completed_form)

    within_frame 'preview' do
      page.should have_content(@form.name)
      page.should have_content(person.name)
    end
  end

  scenario "Clicking 'I am not' the authorized assignee" do
    setup(:public => false)
    person = Fabricate(:person, :account => @account)

    task = Fabricate(:task_with_form_group, :account => @account, :form_group => FormGroup.standalone_for(@form).first, :assignments => [:assignee => person, :form => @form])

    visit form_complete_path(@form, :auth_token => person.authentication_token, :task_id => task.id)
    # landing page, confirm person
    page.should have_content('confirm that you are')
    click_link_or_button('not-person')
    current_path.should == form_complete_path(@form)
  end

  scenario "Trying to complete a private form as a non-auth user" do
    setup(:public => false)
    log_out
    lambda {
      visit form_complete_path(@form)
    }.should raise_error

    page.should have_no_content(@form.name)
  end

  scenario "Trying to complete a private form as a non-assigned person" do
    setup(:public => false)
    task = Fabricate(:task_with_form_group, :account => @account, :form_group => FormGroup.standalone_for(@form).first)
    new_person = Fabricate(:person)

    log_out
    lambda {
      visit form_complete_path(@form, :auth_token => new_person.authentication_token)
    }.should raise_error

    page.should have_no_content(@form.name)
  end

  scenario "Viewing form with template" do
    setup(:public => true)
    @account.create_form_template(:html => "<h1>Test Template Header</h1>")
    visit form_complete_path(@form)
    page.should have_content("Test Template Header")
  end
end
