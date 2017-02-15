require 'spec_helper'

describe FormGroup do
  describe "creating" do
    let(:form_group) { Fabricate(:form_group) }
    let(:form1) { Fabricate(:form) }
    let(:form2) { Fabricate(:form) }

    it "allows multiple forms" do
      form_group.forms = [form1, form2]
      form_group.reload.forms.should == [form1, form2]
    end

    it "is invalid if any forms are not eligible for groups" do
      form_group.forms.concat(Fabricate(:form, :eligible_for_groups => false))
      form_group.reload.should be_invalid
    end
  end

  describe "assigning" do
    let(:task) { Fabricate(:task_with_form_group) }
    let(:form1) { task.form_group.forms.first }
    let(:form2) { task.form_group.forms.second }

    it "allows one of the forms to be assigned to multiple people" do
      task.assignments << Fabricate.build(:assignment, :form => form1)
      task.should be_valid
    end

    it "does not allow more than one form to be assigned to multiple people" do
      task.assignments << Fabricate.build(:assignment, :form => form1)
      task.assignments << Fabricate.build(:assignment, :form => form2)
      task.should_not be_valid
    end

    it "multiplies each singly-assigned form by each assignee in the multiply-assigned form" do
      compliance_officer_id = task.assignments.detect{ |a| a.form_id == form2.id }.assignee_id

      task.assignments << Fabricate.build(:assignment, :form => form1)
      task.assignments << Fabricate.build(:assignment, :form => form1)

      task.should be_valid
      task.assignments.count.should == 6
      task.assignments.select{ |a| a.form_id == form2.id && a.assignee_id == compliance_officer_id }.should have(3).things
    end

    it "makes all but the first assignment dependent on the first if all forms singly assigned" do
      task.should be_valid
      task.assignments.count.should == 2
      task.assignments.first.dependent_assignment_id.should be_nil
      task.assignments.last.dependent_assignment_id.should == task.assignments.first.id
    end

    describe "completing" do
      it "marks the overall task complete when all assignees of form group have completed" do
        task.should_not be_complete

        task.complete!(:person => task.assignees.first)
        task.should_not be_complete

        task.complete!(:person => task.assignees.second)
        task.should be_complete
      end

      it "notifies uncompleted assignees of other forms when assignee completes their form" do
        lambda {
          task.complete!(:person => task.assignees.first)
        }.should change(ActionMailer::Base.deliveries, :count).by(1)
      end

      it "does not notify other assignees of same form when assignee completes their form" do
        task.assignments << Fabricate.build(:assignment, :form => form1)
        task.assignments << Fabricate.build(:assignment, :form => form1)

        # build assignments by calling validation hook
        task.should be_valid
        recruits = task.assignments.select { |a| a.form_id == form1.id }.collect(&:assignee)
        compliance_officer = task.assignments.detect { |a| a.form_id == form2.id }.assignee
        lambda {
          task.complete!(:person => recruits.first)
          task.complete!(:person => recruits.second)
        }.should change(ActionMailer::Base.deliveries, :count).by(2) # once each for the compliance_officer

        ActionMailer::Base.deliveries.last(2).each do |email|
          email.to.should == [ compliance_officer.email ]
        end
      end

      it "does not notify multiply-assigned form assignees when singly-assigned form assignee completes form" do
        task.assignments << Fabricate.build(:assignment, :form => form1)
        task.assignments << Fabricate.build(:assignment, :form => form1)

        recruits = task.assignments.select { |a| a.form_id == form1.id }.collect(&:assignee)
        compliance_officer = task.assignments.detect { |a| a.form_id == form2.id }.assignee

        lambda {
          task.complete!(:person => compliance_officer)
        }.should_not change(ActionMailer::Base.deliveries, :count)
      end
    end

    context "submitting form" do
      let(:form3) {
        person = Fabricate(:person)
        form = Fabricate(:filled_in_form_with_task, :task => task, :assignee => person)
        task.assignments << Fabricate.build(:assignment, :form => form, :assignee => person)
        form
      }

      it "loads completed forms for entire form group" do
        form3.submit!
        form3.completed_forms.should have(1).thing
        task.completed_forms.should == form3.completed_forms
      end

      it "scopes completed forms to particular assignee of other form in form group" do
        pending
      end
    end
  end

  describe "counting" do
    let!(:form_group) { Fabricate(:form_group_with_completed_forms) }
    it "should count all completed forms" do
      FormGroup.completed_form_counts[form_group.id][form_group.form_ids.first.to_s].should == 3
    end

    it "should count program level completed forms" do
      4.times { Fabricate(:completed_form, :program => form_group.program, :form_group => form_group, :form => form_group.forms.first) }
      FormGroup.completed_form_counts(form_group.program)[form_group.id][form_group.form_ids.first.to_s].should == 4
    end
  end
end
