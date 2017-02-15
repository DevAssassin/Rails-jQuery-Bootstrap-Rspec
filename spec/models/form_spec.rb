require 'spec_helper'

describe Form do

  it { should validate_presence_of :name }
  it { should validate_presence_of :html }

  context "creating" do

    context "sanitizing html form" do
      before :each do
        @form = Fabricate(:form)
        @sanitized_html = Nokogiri::HTML(@form.sanitized_html)
      end

      it "creates :sanitized_html" do
        @form.sanitized_html.should_not be_nil
      end

      it "parses and namespaces inputs properly" do
        sanitized_inputs = @sanitized_html.search('//input[@type="text"]', '//textarea', '//select', '//input[@type="checkbox"]', '//input[@type="radio"]')
        sanitized_inputs.should have(8).things

        sanitized_inputs[0].attribute('name').value.should == "completed_form_data[hi]"
        sanitized_inputs[1].attribute('name').value.should == "completed_form_data[whats_up]"
        sanitized_inputs[2].attribute('name').value.should == "completed_form_data[pick_one][again]"
        sanitized_inputs[3].attribute('name').value.should == "completed_form_data[mood][]"
        sanitized_inputs[6].attribute('name').value.should == "completed_form_data[hey]"
      end

      it "parses and namespaces labels" do
        labels = @sanitized_html.search('//label')
        labels.should have(3).things

        labels.first.attribute('for').value.should == "completed_form_data[hi]"
        labels[1].attribute('for').value.should == "completed_form_data[whats_up]"
        labels[2].attribute('for').value.should == "completed_form_data[pick_one][again]"
      end

    end

    context "a long complex form" do
      before :each do
        @form = Fabricate(:large_form)
        @sanitized_html = Nokogiri::HTML(@form.sanitized_html)
      end

      it "strips out form tag if present" do
        form_tag = @sanitized_html.search('//form')
        form_tag.should be_empty
      end

      it "does not strip out inputs contained in form" do
        original_inputs = Nokogiri::HTML(@form.html).search('//input','//textarea','//select')
        sanitized_inputs = Nokogiri::HTML(@form.sanitized_html).search('//input','//textarea','//select')
        sanitized_inputs.size.should == original_inputs.size - 3 # minus file input and submit inputs which also get stripped out
      end

      it "strips out submit input if present" do
        submit_input = @sanitized_html.search('//input[@type="submit"]')
        submit_input.should be_empty
      end

      it "strips out file input field if present" do
        file_input = @sanitized_html.search('//input[@type="file"]')
        file_input.should be_empty
      end
    end

    context "for standalone/grouped use" do
      describe "allowing as a standalone or grouped form" do

        it "is invalid without either standalone or grouped eligibility" do
          form = Fabricate(:form)
          form.eligible_for_groups = false
          form.eligible_for_standalone = false

          form.should be_invalid
        end

        it "provides this by default" do
          form = Form.new
          form.should be_standalone_and_grouped
        end

        it "creates a standalone form_group for form" do
          form = Fabricate(:form)
          FormGroup.standalone_for(form).count.should == 1
        end

        it "is included in new form_group options" do
          new_form = Fabricate(:form)
          Form.eligible_for_groups.to_a.should include(new_form)
        end
      end

      describe "allowing only as standalone form" do
        before :each do
          @form = Fabricate(:form, :eligible_for_groups => false)
        end

        it "creates a standalone form_group for form" do
          FormGroup.standalone_for(@form).count.should == 1
        end

        it "is not included in new form_group options" do
          Form.eligible_for_groups.to_a.should_not include(@form)
        end
      end

      describe "allowing only as a grouped form" do
        before :each do
          @form = Fabricate(:form, :eligible_for_standalone => false)
        end

        it "does not create a standalone form_group for form" do
          FormGroup.standalone_for(@form).count.should == 0
        end

        it "is included in new form_group options" do
          Form.eligible_for_groups.to_a.should include(@form)
        end
      end

    end
  end

  context "submitting" do
    before :each do
      @form = Fabricate(:filled_in_form)
    end

    it "creates a completed_form when submitted" do
      @form.submit!
      @form.completed_forms.should have(1).thing
      @form.completed_forms.first.data.should == @form.completed_form_data
    end

    it "caches viewed form when submitted" do
      @form.submit!
      @form.completed_forms.first.form_html.should == @form.sanitized_html
    end

    it "caches the html viewed by assignee, if form is changed while assignee is completing" do
      pending
    end
  end

  context "submitting with task" do
    before :each do
      @form = Fabricate(:filled_in_form_with_task)
    end

    it "does not allow form with task to be re-submitted after task is complete" do
      lambda {
        @form.submit!
      }.should change(CompletedForm, :count).by(1)

      lambda {
        @form.reload.submit!
      }.should raise_error
    end

    it "does not overwrite completed form if task is re-submitted" do
      @form.submit!
      completed_form_id = @form.task.assignments.first.completed_form_id
      lambda {
        @form.reload.submit!
      }.should raise_error
      @form.reload.task.assignments.first.completed_form_id.should == completed_form_id
    end
  end

  context "pending and completed" do
    before :each do
      @form = Fabricate(:form)
      @task = Fabricate(:task, :form => @form)
    end

    def submit
      @form.completed_form_data = {"hi" => "there"}
      @form.submit!
    end

    it "has pending_forms when a task is created" do
      @form.pending_forms.should have(1).thing
      @form.pending_forms.first.should == @task
    end

    it "sets task from person auth token" do
      @form.set_assignee_and_task(@task.assignee.authentication_token)
      @form.task.should == @task
    end

    it "raises error if authentication_token not found" do
      lambda {
        @form.set_assignee_and_task('blah')
      }.should raise_error(Mongoid::Errors::DocumentNotFound)
    end

    it "raises error if person is not assigned a task to form" do
      person = Fabricate(:person)
      lambda {
        @form.set_assignee_and_task(person.authentication_token)
      }.should raise_error(Mongoid::Errors::DocumentNotFound)
    end

    it "marks a task (pending_form) complete when submitted" do
      person = @task.assignee
      @form.task = @task
      submit
      @task.should be_completed
      @form.pending_forms.should have(0).things
      @form.completed_forms.should have(1).thing
    end

    it "associates the completed_form with the task" do
      @form.task = @task
      submit
      # refresh from db
      completed_form = CompletedForm.find(@form.completed_forms.first.id)
      completed_form.task.should == @task
    end

    it "sets the correct task when same form assigned to same assignee multiple times" do
      assignee = @task.assignee
      other_task = Fabricate(:task, :form => @form, :assignee => assignee)
      @form.tasks.should have(2).things
      assignee.assigned_tasks.should have(2).things

      @form.set_assignee_and_task(assignee.authentication_token, @task.id)
      @form.task.should == @task

      @form.set_assignee_and_task(assignee.authentication_token, other_task.id)
      @form.task.should == other_task
    end
  end

  context "completing with form group" do
    before :each do
      @task = Fabricate(:task_with_form_group)
      @form_group = @task.form_group
      @form1 = @form_group.forms.first
      @form2 = @form_group.forms.second

      @person = @task.assignees.first
      @officer = @task.assignees.second
      @task.assignments << Fabricate.build(:assignment, :form => @form1)
      # Trigger creation of the dependent assignments
      @task.valid?
    end

    def submit
      @form.completed_form_data = {"hi" => "there"}
      @form.submit!
    end

    it "sets assignment if person has multiple assignments for task (i.e. dependent on another form in form group)" do
      assignments = @task.assignments.select{ |a| a.assignee_id == @officer.id }
      assignments.should have(2).things
      @form2.set_assignee_and_task(@officer.authentication_token, @task.id, assignments.second.id)
      @form2.assignment.should == assignments.second
    end
  end

  context "deleting" do
    it "allows a form with no completed or pending forms to be deleted" do
      form = Fabricate(:form)
      form.should be_deletable
    end

    it "does not allow a form with completed forms to be deleted" do
      form = Fabricate(:filled_in_form)
      form.submit!
      form.should_not be_deletable
    end

    # TODO: we should maybe allow this at some point, but then we'll need to
    # program up the functionality for alerting people with the pending assignments
    # and have some sort of message for people who try to access the form-submit URL
    it "does not allow a form with pending assignments to be deleted" do
      form = Fabricate(:form, :tasks => [Fabricate(:task)])
      form.should_not be_deletable
    end
  end
end
