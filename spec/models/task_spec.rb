require 'spec_helper'

describe Task do

  it { should validate_presence_of :name }

  context "creating" do
    before :each do
      @task = Fabricate(:task)
    end

    it "gets added to user's list of tasks" do
      @task.user.tasks.to_a.should == [@task]
    end

    it "gets added to account's list of tasks" do
      @task.account.tasks.to_a.should == [@task]
    end

    it "gets added to program's list of tasks" do
      program = Fabricate(:program, :account => @account)
      @task.program = program
      @task.save
      program.tasks.to_a.should == [@task]
    end

    it "gets added to assignee's list of assigned tasks" do
      person = @task.assignee
      other_person = Fabricate(:person, :account => @task.account)

      person.assigned_tasks.to_a.should == [@task]

      @task.assignees = [@task.assignee, other_person]
      other_task = Fabricate(:task, :assignees => [person, other_person])

      person.assigned_tasks.to_a.should =~ [@task, other_task]
    end

    it "completes assignment" do
      lambda {
        @task.complete!
      }.should change(@task, :completed_at).from(nil)
    end

    it "is incomplete" do
      @task.should_not be_completed
      Task.incomplete.to_a.should include(@task)
    end

    it "marks incomplete assignment" do
      @task.complete!
      lambda {
        @task.incomplete!
      }.should change(@task, :completed_at).to(nil)
    end

    it "sorts by due_date" do
      task2 = Fabricate(:task_with_deadline, :due_at => 3.days.from_now)
      task3 = Fabricate(:task_with_deadline, :due_at => 1.hour.from_now)

      # Mongoid spec (this should really be in mongoid's test suite, not ours)
      Task.sorted_by_due.options.should == {:sort=>[[:due, :desc], [:due_at, :asc], [:completed_at, :asc], [:created_at, :asc]]}
      # This is the real spec we should be worried about
      Task.sorted_by_due.to_a.should == [ task3, task2, @task ]
    end

    context "completing" do
      before :each do
        @task.complete!
      end

      it "is not incomplete" do
        @task.should be_completed
        Task.incomplete.to_a.should_not include(@task)
      end

      it "adds to completed tasks" do
        other_task = Fabricate(:task)
        tasks = Task.completed.to_a
        tasks.should include(@task)
        tasks.should_not include(other_task)
      end
    end
  end

  # TODO: Move these specs to assignment_spec for the new Assignment relation
  context "assigning" do
    it "ensures person has authentication_token before assigning" do
      person = Fabricate(:person)
      person.authentication_token = nil
      task = Fabricate(:task, :assignee => person)
      person.reload.authentication_token.should_not be_nil
    end

    context "to multiple people" do
      before :each do
        @person = Fabricate(:person)
        @other_person = Fabricate(:person)
        @task = Fabricate(:task, :assignees => [@person, @other_person])
      end

      it "doesn't mark task complete until all assignees have completed" do
        @task.should_not be_complete

        @task.complete!(:person => @person)
        @task.should_not be_complete

        @task.complete!(:person => @other_person)
        @task.should be_complete
      end

      it "marks task complete for each assignee to complete it" do
        @task.completed_by?(@person).should be_false
        @task.completed_by?(@other_person).should be_false

        @task.complete!(:person => @person)
        @task.completed_by?(@person).should be_true
        @task.completed_by?(@other_person).should be_false

        @task.complete!(:person => @other_person)
        @task.completed_by?(@person).should be_true
        @task.completed_by?(@other_person).should be_true
      end

      it "marks task incomplete for an assignee and also marks overall task incomplete" do
        @task.complete!(:person => @person)
        @task.completed_by?(@person).should be_true

        @task.incomplete!(@person)
        @task.completed_by?(@person).should be_false
        @task.should_not be_completed
      end

      it "deletes a task for specific assignee without deleting task for other assignees" do
        @task.delete_for_assignee(@person)
        @person.assigned_tasks.should_not include(@task)
        @other_person.assigned_tasks.should include(@task)
      end

      it "marks task complete if only uncompleted assignee is deleted" do
        @task.complete!(:person => @other_person)
        @task.should_not be_completed
        @task.delete_for_assignee(@person)
        @task.should be_completed
      end

      it "deletes the task if only assignee is deleted" do
        @task.delete_for_assignee(@person)
        @task.delete_for_assignee(@other_person)
        lambda {
          @task.reload
        }.should raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end

    context "and sending out notification" do
      before :each do
        @emails = setup_action_mailer_testing
      end

      it "sends notification if assignee has email" do
        person = Fabricate(:person, :email => "hi@example.com")
        task = Fabricate(:task, :assignee => person)

        @emails.should have(1).thing
        email = @emails.first
        email.subject.should =~ /assigned a task/i
        email.to.should == ["hi@example.com"]
      end

      it "does not send notification if assignee has no email" do
        person = Fabricate(:person, :email => "")
        task = Fabricate(:task, :assignee => person)

        @emails.should have(0).things
      end

      it "sends notification to multiple assignees" do
        people = [Fabricate(:person, :email => "hi@example.com"), Fabricate(:person, :email => "bye@example.com")]
        task = Fabricate(:task, :assignees => people)

        @emails.should have(2).things
      end

      it "doesn't send notification if skip_notify true" do
        person = Fabricate(:person, :email => "hi@example.com")
        task = Fabricate(:task, :assignee => person, :skip_notify => true)

        @emails.should have(0).things
      end

      it "sends notification to assignees added, but not to those already assigned" do
        pending
      end

      it "sends notification to first form assignees but not others" do
        form_group = Fabricate(:other_form_group)
        task = Fabricate(:task_with_form_group_and_assignees, :form_group => form_group)
        @emails.should have(1).things
      end

      it "sends notification to next assignee but not all assignees when > 2 forms in form group" do
        form_group = Fabricate(:other_form_group)
        task = Fabricate(:task_with_form_group, :form_group => form_group, :skip_notify => true)
        task.complete!(:person => task.assignments.first.assignee)
        @emails.should have(1).things
      end
    end
  end

  context "with deadline" do
    before :each do
      @task = Fabricate(:task_with_deadline)
    end

    it "is selected by past_due scope if past-due" do
      no_deadline = Fabricate(:task)
      past_deadline = Fabricate(:task_with_deadline, :due_at => 1.hour.ago)
      completed = Fabricate(:task_with_deadline, :due_at => 1.hour.ago, :completed_at => Time.now)

      past_due = Task.past_due.to_a
      past_due.should =~ [past_deadline]
    end

    it "is past due if incomplete with past deadline" do
      @task.due_at = 1.hour.ago
      @task.should be_past_due
    end

    it "is not past due if incomplete with future deadline" do
      @task.due_at = 1.hour.from_now
      @task.should_not be_past_due
    end

    it "is not past due if complete" do
      @task.due_at = 1.hour.ago
      @task.complete!
      @task.should_not be_past_due
    end

    it "is not past due without deadline" do
      @task.due_at = nil
      @task.should_not be_past_due
    end

    it "adds error when it can't parse a due date" do
      @task.due_at = "lksafadskjlkj3"
      @task.valid?
      @task.errors[:due_at].should be_present
    end

    it "doesn't add error when due date blank" do
        @task.due_at = ""
        @task.valid?
        @task.errors.should be_blank
    end
  end

  describe "mass update" do
    before :each do
      3.times { |i| instance_variable_set("@task#{i+1}", Fabricate(:task))}
      @selected_tasks = [@task1, @task3]
      @unselected_tasks = [@task2]
    end

    it "marks all selected tasks completed, given 'complete' action" do
      @selected_tasks.each { |t| t.should_not be_completed }
      Task.mass_update(@selected_tasks, 'complete')
      @selected_tasks.each { |t| t.should be_completed }
      @unselected_tasks.each { |t| t.should_not be_completed }
    end

    it "destroys all selected tasks, given 'delete' action" do
      Task.all.to_a.should =~ [@task1, @task2, @task3]
      Task.mass_update(@selected_tasks, 'delete')
      Task.all.to_a.should =~ @unselected_tasks
    end
  end

  describe "human-readable due_at" do
    it "parses basic human-readable deadline" do
      pending
      t = Task.new(:due_at => "tomorrow")
      t.due_at.to_date.should == 1.day.from_now.to_date
    end
  end

  describe "deleting" do
    before :each do
      @form = Fabricate(:filled_in_form_with_task)
      @task = @form.task
      @form.submit!
    end

    it "can't be deleted if it has completed forms already" do
      @task.destroy.should == false
      @task.errors.messages.should have_key :completed_forms
      @task.reload.should == @task
    end
  end
end
