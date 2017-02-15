require 'acceptance/acceptance_helper'

feature "Tasks", %q{
  In order to track tasks
  As a coach
  I want to create and assign tasks to contacts
} do

  background do
    log_in
    change_scope(@account)
  end

  after :each do
    Delayed::Worker.delay_jobs = false
  end

  def setup
    @coach = Fabricate(:coach, :account => @account, :program => @program, :first_name => 'Lloyd', :last_name => 'Carr')
    @form = Fabricate(:form, :account => @account, :name => 'Some Form')
  end

  scenario "Creating a task from the tasks page", :js => true do
    setup
    visit tasks_path

    click_link 'Create Task'

    fill_in 'task_name', :with => 'Some new task'
    fill_in 'task_description', :with => 'Do something please. This is important.'

    click_link "Assign form"
    # TODO: Make user from assignee_ids_string carries over to first form in form group
    select 'Some Form', :from => 'task_form_group_id'
    page.should have_field("task[form_group_assignments][#{@form.id}][assignee_ids_string]")

    fill_in "token-input-task_form_group_assignments_#{@form.id}_assignee_ids_string", :with => 'Lloyd'
    page.should have_content 'Lloyd Carr'
    find('li', :text => 'Lloyd Carr').click
    within '#task-form-group-assignments' do
      page.should have_content 'Lloyd Carr'
    end

    fill_in 'task_due_at', :with => 'next week'

    click_button 'Save'

    current_path.should == person_path(@coach)
    within '#task-list-form' do
      page.should have_content 'Some new task'
    end

    visit dashboard_path(@program)
    within '.interaction-list .type' do
      page.should have_content "Assigned"
    end

    within '.interaction-list .name' do
      page.should have_content @coach.name
    end
  end

  scenario "Creating a generic task (not assigned, no form)" do
    visit new_task_path

    fill_in 'task_name', :with => 'Some new task'

    click_button 'Save'

    current_path.should == tasks_path
    page.should have_content 'Some new task'
  end

  scenario "Assigning a task from a specific contact profile", :js => true do
    setup
    visit person_path(@coach)

    click_link "Assign Task"

    current_path.should == new_task_path
    within "#task-assignees-string" do
      page.should have_content @coach.name
    end
  end

  scenario "Assinging a task from a specific form" do
    setup
    visit form_path(@form)

    click_link "Assign Form"

    current_path.should == new_task_path
    find_by_id('task_form_group_id').find('option', :text => 'Some Form').should be_selected
  end

  scenario "Clicking a task to view details", :js => true do
    setup
    task = Fabricate(:task, :account => @account, :name => 'Some task', :description => 'Stuff', :assignee => @coach)

    visit tasks_path

    find('span.task-info', :text => 'Some task').click
    find('p', :text => 'Stuff').should be_visible
  end

  scenario "Marking a task complete on the tasks page", :js => true do
    task = Fabricate(:task, :account => @account, :name => 'Some task')

    visit tasks_path

    find('span.task-info', :text => 'Some task').click
    click_link('Mark complete')
    find('li.task', :text => 'Some task')[:class].should include('completed')

    # TODO: Do we also want task to be marked completed for each assignee?

    visit completed_tasks_path
    find('span.task-info', :text => 'Some task').click
    click_link('Mark incomplete')
    find('li.task', :text => 'Some task')[:class].should_not include('completed')
  end

  scenario "Marking a task complete on the assignee's page", :js => true do
    person = Fabricate(:coach, :account => @account, :program => @program)
    other_person = Fabricate(:coach, :account => @account, :program => @program)
    task = Fabricate(:task, :account => @account, :name => 'Some task', :assignees => [person, other_person])

    visit person_path(person)

    find('span.task-info', :text => 'Some task').click
    click_link('Mark complete')

    # Task should show completed on assignee's profile
    find('li.task', :text => 'Some task')[:class].should include('completed')

    # Task should not show completed on tasks page since other_person has not completed
    visit tasks_path
    find('li.task', :text => 'Some task')[:class].should_not include('completed')

    visit person_path(other_person)

    find('span.task-info', :text => 'Some task').click
    click_link('Mark complete')

    # Task should now show completed on all pages
    click_link 'View completed'
    find('li.task', :text => 'Some task')[:class].should include('completed')

    # Marking incomplete from assignee's page should also mark overall task incomplete
    visit completed_person_tasks_path(person)
    find('span.task-info', :text => 'Some task').click
    click_link('Mark incomplete')
    find('li.task', :text => 'Some task')[:class].should_not include('completed')

    visit person_path(person)
    find('li.task', :text => 'Some task')[:class].should_not include('completed')

    visit tasks_path
    find('li.task', :text => 'Some task')[:class].should_not include('completed')

    visit dashboard_path(@program)
    within '.interaction-list .type' do
      page.should have_content "Completed"
    end

    page.should have_selector('.interaction-list .task-completed .name', :text => person.name)
    page.should have_selector('.interaction-list .task-completed .name', :text => other_person.name)
  end

  scenario "Deleting a task", :js => true do
    task = Fabricate(:task, :account => @account, :name => 'Some task')

    visit tasks_path

    find('span.task-info', :text => 'Some task').click
    accept_js_confirm do
      click_link('Delete')
    end
    within '#task-list-form' do
      page.should have_no_content('Some task')
    end
  end

  scenario "Editing a task", js: true do
    setup
    task = Fabricate(:task_with_threads, :account => @account, :name => 'Some task')
    assignment = task.assignments.first
    form = assignment.form
    assignee = assignment.assignee

    # Create completed form
    form.set_assignee_and_task(assignee.authentication_token, task.id, assignment.id)
    form.completed_form_data = { hi: 'there' }
    form.submit!

    visit tasks_path

    find('span.task-info', :text => 'Some task').click
    click_link('Edit')

    current_path.should == edit_task_path(task)

    fill_in 'task_name', :with => 'Some edited task'

    # Create new parent assignment
    page.should have_field("task[form_group_assignments][#{form.id}][assignee_ids_string]")
    fill_in "token-input-task_form_group_assignments_#{form.id}_assignee_ids_string", :with => 'Lloyd'
    page.should have_content 'Lloyd Carr'
    find('li', :text => 'Lloyd Carr').click

    click_button('Save')

    # Assignments should be updated to create new dependent assignments from new parent assignment
    task.reload.assignments.should have(6).things

    current_path.should == tasks_path
    within '#task-list-form' do
      page.should have_no_content('Some task')
      page.should have_content('Some edited task')

      within '.task-assignee' do
        # Assignment should stay associated with completed form and status
        find('a.assignee-name', :text => assignee.name)[:class].should include('completed')
        page.should have_content ('Lloyd Carr')
      end
    end

    visit edit_task_path(task)

    # This isn't working as Capybara's docs says it should
    #find('li', :text => 'Lloyd Carr').find('span.token-input-delete-token-facebook').click
    find(:xpath, '//li[contains(., "Lloyd Carr")]/span').click
    click_button('Save')

    current_path.should == tasks_path

    # Dependent assignments should be deleted along with parent assignment
    task.reload.assignments.should have(4).things

    visit edit_task_path(task)

    find(:xpath, "//li[contains(., '#{assignee.name}')]/span").click
    click_button('Save')

    current_path.should == task_path(task)
    page.should have_content "already have completed forms"

    visit tasks_path
    within '#task-list-form' do
      within '.task-assignee' do
        page.should have_content assignee.name
      end
    end
  end

  scenario "Editing a task to add more assignees should only send email to new one", js: true do
    setup
    task = Fabricate(:task_with_threads, :account => @account, :name => 'Some task')
    assignment = task.assignments.first
    form = assignment.form
    Fabricate(:coach, :account => @account, :program => @program, :first_name => 'First', :last_name => 'Coach', :email => 'first@test.com')
    Fabricate(:coach, :account => @account, :program => @program, :first_name => 'Second', :last_name => 'Coach', :email => 'second@test.com')
    original_email_count = ActionMailer::Base.deliveries.count
    visit edit_task_path(task)

    page.should have_field("task[form_group_assignments][#{form.id}][assignee_ids_string]")
    fill_in "token-input-task_form_group_assignments_#{form.id}_assignee_ids_string", :with => 'First'
    page.should have_content 'First Coach'
    find('li', :text => 'First Coach').click
    page.should have_content 'First Coach'

    click_button('Save')

    new_email_count = ActionMailer::Base.deliveries.count - original_email_count
    new_email_count.should == 1

    #assign the other coach
    visit edit_task_path(task)

    page.should have_field("task[form_group_assignments][#{form.id}][assignee_ids_string]")
    fill_in "token-input-task_form_group_assignments_#{form.id}_assignee_ids_string", :with => 'Second'
    page.should have_content 'Second Coach'
    find('li', :text => 'Second Coach').click
    page.should have_content 'First Coach'
    page.should have_content 'Second Coach'

    click_button('Save')

    new_email_count = ActionMailer::Base.deliveries.count - original_email_count
    new_email_count.should == 2 #in other words, another new one, not two new ones
  end

  scenario "Sending a task reminder from tasks page", :js => true do
    change_scope @account

    person = Fabricate(:coach, :account => @account, :program => @program, :email => "hi@example.com")
    other_person = Fabricate(:coach, :account => @account, :program => @program, :email => "bye@example.com")
    task = Fabricate(:task, :account => @account, :name => 'Some task', :assignees => [person, other_person])

    visit tasks_path

    find('span.task-info', :text => 'Some task').click
    click_link('Send reminder')

    # New Email page with task-reminder template
    current_path.should == new_email_path
    page.should have_content 'hi@example.com'
    page.should have_content 'bye@example.com'
    page.should have_content 'Task Name:'
    fill_in 'email_subject', :with => 'Reminder yo'
    click_button('Send')

    current_path.should == tasks_path
    find('span', :text => 'Some task').click
    within '.task-drawer' do
      page.should have_content 'Reminder yo'
    end

    # Make sure we don't display the 'Send reminder' button if a task has no assignees
    task.assignments.clear
    visit tasks_path
    find('span', :text => 'Some task').click
    within "#task-#{task.id}" do
      page.should have_no_content('Send reminder')
    end
  end

  # A lot of this should really be in the acceptance/email_spec,
  # but tasks are the only things that let you schedule an email prior
  # to a certain date, and I wanted to test switching between scheduling
  # prior to a future date and a certain amount of time after today's date
  scenario "Sending a scheduled task reminder", :js => true do
    Delayed::Worker.delay_jobs = true
    emails = ActionMailer::Base.deliveries
    @user.time_zone = "UTC"
    @user.save

    person = Fabricate(:coach, :account => @account, :program => @program, :email => "hi@example.com")
    task = Fabricate(:task, :account => @account, :name => 'Some task', :assignees => [person], :due_at => 4.weeks.from_now)

    visit new_email_path(:task => task.id, :to => [person.id])

    click_link "Schedule to send later"
    # Make sure button text updates
    within('#content') do
      page.should have_button "Schedule"
      page.should have_no_button "Send"
    end

    # Fill out schedule
    email_subject = 'This is a reminder!'
    fill_in 'email_subject', :with => email_subject
    select "1", :from => "email_schedule_attributes_amount"
    select "weeks", :from => "email_schedule_attributes_unit"
    select "before due", :from => "email_schedule_attributes_relative_direction"

    # Email should be scheduled and not sent out
    # (the only email should be the one automatically sent when assigned)
    lambda {
      click_button "Schedule"
    }.should_not change(emails, :size)

    within '.notice' do
      page.should have_content "Your email was scheduled successfully"
    end

    # Make sure scheduled email is listed as scheduled
    current_path.should == scheduled_emails_path
    page.should have_link email_subject
    page.should have_content task.name
    # HACK: some weird bug in strftime causes '%l' (e.g. '1' in 1:00) to be represented as ' 1:00'
    # while '12:00' is just '12:00', so single digits get an extra space, which
    # HTML pages then strip out and only show one space where there are 2 or more
    page.should have_content (task.due_at - 1.week).to_formatted_s.gsub(/\s+/, ' ')

    # Edit scheduled email
    click_link email_subject
    page.should have_select 'email_schedule_attributes_amount', :selected => "1"
    page.should have_select 'email_schedule_attributes_unit', :selected => "weeks"
    page.should have_select 'email_schedule_attributes_relative_direction', :selected => "before due"

    # Change email to be sent out 3 days from now
    select "3", :from => "email_schedule_attributes_amount"
    select "days", :from => "email_schedule_attributes_unit"
    select "from now", :from => "email_schedule_attributes_relative_direction"

    # Email should still be scheduled and not sent out
    lambda {
      click_button "Save"
    }.should_not change(emails, :size)

    # Make sure scheduled email has updated schedule
    current_path.should == scheduled_emails_path
    page.should have_content (Time.zone.now + 3.days).to_formatted_s.gsub(/\s+/, ' ')

    # Edit again to remove schedule
    click_link email_subject

    click_link "Cancel schedule"

    # 'Save' button should be updated to say 'Send' to make it clear that it will now be sent
    page.should have_button "Send"
    page.should have_no_button "Save"

    lambda {
      accept_js_confirm do
        click_button "Send"
      end
    }.should_not change(emails, :size)

    Email.last.job.run_at.should < Time.zone.now + 1.hour

    # Email should be sent immediately
    within '.notice' do
      page.should have_content EmailsController::EmailSent
    end

    # Make sure email is no longer listed in scheduled emails
    visit scheduled_emails_path
    page.should have_no_content email_subject
  end

  scenario "Sending a task reminder from assignee page", :js => true do
    person = Fabricate(:coach, :account => @account, :program => @program, :email => "hi@example.com")
    other_person = Fabricate(:coach, :account => @account, :program => @program, :email => "bye@example.com")
    task = Fabricate(:task, :account => @account, :name => 'Some task', :assignees => [person, other_person])

    visit person_path(person)

    find('span.task-info', :text => 'Some task').click
    click_link('Send reminder')

    current_path.should == new_email_path
    page.should have_content "<hi@example.com>"
    page.should have_no_content "<bye@example.com>"
  end

  scenario "Sending task reminder only sends to assignees with email addresses", :js => true do
    person = Fabricate(:coach, :account => @account, :program => @program, :email => "hi@example.com")
    other_person = Fabricate(:coach, :account => @account, :program => @program, :email => nil)
    task = Fabricate(:task, :account => @account, :name => 'Some task', :assignees => [person, other_person])

    visit tasks_path

    find('span.task-info', :text => 'Some task').click
    click_link('Send reminder')

    current_path.should == new_email_path
    page.should have_content "hi@example.com"
    within "form" do
      page.should have_no_content other_person.name
    end
    within '.notice' do
      page.should have_content other_person.name
    end
  end

  scenario "Mass-assigning tasks from contacts page", :js => true do
    person = Fabricate(:coach, :account => @account)
    other_person = Fabricate(:coach, :account => @account)
    third_person = Fabricate(:coach, :account => @account)
    change_scope(@account)

    visit coaches_path

    page.check("person-checkbox-#{person.id}")
    page.check("person-checkbox-#{third_person.id}")

    within "#mass-actions" do
      click_link_or_button('Assign Task')
    end

    current_path.should == new_task_path
    within "#task-assignees-string" do
      page.should have_content person.name
      page.should have_content third_person.name
      page.should have_no_content other_person.name
    end

  end

  context "Mass-actions for tasks" do

    background do
      @assignee = Fabricate(:coach, :account => @account, :program => @program)
      @task1 = Fabricate(:task, :account => @account, :assignees => [@assignee], :name => 'Some task')
      @task2 = Fabricate(:task, :account => @account, :assignees => [@assignee], :name => 'Some other task')
      @task3 = Fabricate(:task, :account => @account, :assignees => [@assignee], :name => 'Another task')
    end

    scenario "Mass-deleting tasks from the tasks page", :js => true do
      visit tasks_path

      page.check("task-checkbox-#{@task1.id}")
      page.check("task-checkbox-#{@task3.id}")

      accept_js_confirm do
        within '#mass-actions' do
          click_link_or_button('Delete')
        end
      end

      within '#task-list-form' do
        page.should have_no_content('Some task')
        page.should have_no_content('Another task')

        page.should have_content('Some other task')
      end
    end

    scenario "Mass-marking tasks complete from the tasks page", :js => true do
      visit tasks_path

      page.check("task-checkbox-#{@task1.id}")
      page.check("task-checkbox-#{@task3.id}")

      within '#mass-actions' do
        click_link_or_button('Mark Complete')
      end

      within '#task-list-form' do
        find('li.task', :text => 'Some task')[:class].should include('completed')
        find('li.task', :text => 'Another task')[:class].should include('completed')

        find('li.task', :text => 'Some other task')[:class].should_not include('completed')
      end
    end

    scenario "Mass-marking tasks complete from assignee's page", :js => true do
      other_person = Fabricate(:coach, :account => @account, :program => @program)
      [@task1, @task3].each do |t|
        t.assignees = [@assignee, other_person]
      end

      visit person_path(@assignee)

      page.check("task-checkbox-#{@task1.id}")
      page.check("task-checkbox-#{@task3.id}")

      within '#mass-actions' do
        click_link_or_button('Mark Complete')
      end

      # Tasks should be marked complete on assignee's page
      within '#task-list-form' do
        find('li.task', :text => 'Some task')[:class].should include('completed')
        find('li.task', :text => 'Another task')[:class].should include('completed')
      end

      # Make sure the view logic checks out, not just the js feedback
      visit completed_person_tasks_path(@assignee)
      within '#task-list-form' do
        find('li.task', :text => 'Some task')[:class].should include('completed')
        find('li.task', :text => 'Another task')[:class].should include('completed')
      end

      # Tasks should not be marked complete on overall tasks page
      visit tasks_path
      within '#task-list-form' do
        find('li.task', :text => 'Some task')[:class].should_not include('completed')
        find('li.task', :text => 'Another task')[:class].should_not include('completed')
      end
    end
  end
end
