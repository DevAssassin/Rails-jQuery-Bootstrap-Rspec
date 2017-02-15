require 'spec_helper'

describe CompletedForm do
  context "creating without task" do
    before :each do
      @form = Fabricate(:filled_in_form)
      @form.submit!
      @completed_form = @form.completed_forms.first
    end

    it "sets account from form" do
      @completed_form.should_not be_nil
      @completed_form.account.should == @form.account
    end

    it "stores the anonymous person's name as the submitter" do
      @completed_form.submitter_name.should == "Steve Schwartz"
    end
  end

  context "creating with task" do
    before :each do
      @form = Fabricate(:filled_in_form_with_task)
      @form.submit!
      @completed_form = @form.completed_forms.first
    end

    it "sets task from form" do
      @completed_form.task.should_not be_nil
      @completed_form.task.should == @form.task
    end

    it "sets assignee from task" do
      @completed_form.assignee.should_not be_nil
      @completed_form.assignee.should == @form.task.assignee
    end

    it "sets the assignee's name as the submitter" do
      @completed_form.submitter_name.should == @form.task.assignee.name
    end
  end

  context "filled-in values" do
    before :each do
      @form = Fabricate(:filled_in_form)
      @form.submit!
      @completed_form = @form.completed_forms.first
      @data = Nokogiri::HTML(@completed_form.form_html_with_data)
    end

    it "fills in form html with input values" do
      input = @data.search('//input').first
      input['value'].should == "there"
    end

    it "fills in form html with textarea values" do
      textarea = @data.search('//textarea').first
      textarea.content.should == "I'm a recruit."
    end

    it "fills in form html with select values" do
      selected = @data.search('//select/option[@selected]').first
      selected['value'].should == "Arizona"
    end

    it "fills in form html with checkbox values" do
      checked = @data.search('//input[@type="checkbox"][@checked]')
      checked.should have(2).things
      checked.collect{ |c| c['value'] }.should =~ ['happy', 'funtime']
    end

    it "fills in form html with radio values" do
      selected = @data.search('//input[@type="radio"][@checked]').first
      selected['value'].should == 'now'
    end
  end

  describe "deleting" do
    let(:form) { Fabricate(:filled_in_form_with_task) }
    let(:completed_form) { form.submit!; form.completed_forms.first }

    it "does not allow deletion by non-admins" do
      user = Fabricate(:user)
      completed_form.should_not be_destroyable_by(user)
      CompletedForm.should_not be_destroyable_by(user)
    end

    it "allows deletion by admin" do
      user = Fabricate(:admin)
      completed_form.should be_destroyable_by(user)
      CompletedForm.should be_destroyable_by(user)
    end

    it "updates associated assignment and marks as incomplete" do
      assignment = completed_form.task.assignments.where(:_id => completed_form.assignment_id).first
      lambda {
        completed_form.destroy
      }.should change(assignment, :completed_at).to(nil)
      assignment.completed_form_id.should be_nil
    end

    context "in threads" do
      let(:task) { Fabricate(:task_with_threads) }
      let(:assignments) { task.assignments }
      let(:assignees) { task.assignees }
      let(:forms) { task.form_group.forms }
      let(:completed_forms) {
        assignments.collect { |a|
          a.form.set_assignee_and_task(a.assignee.authentication_token, task.id, a.id)
          a.form.completed_form_data = {:hi => 'there'}
          a.form.submit!
          a.reload.completed_form
        }
      }
      let(:grouped) { CompletedForm.to_grouped(completed_forms) }
      let(:thread_ids) { assignments.collect(&:dependent_assignment_id).reject(&:nil?).uniq.collect(&:to_s) }

      it "deletes every completed form in a thread" do
        completed_forms
        CompletedForm.destroy_all_by_thread_id(thread_ids.first)
        CompletedForm.where(:_id.in => grouped.first[:individual_completed_forms].collect(&:id)).to_a.should be_empty
      end

      it "doesn't delete completed forms from the same task in a different thread" do
        completed_forms
        CompletedForm.destroy_all_by_thread_id(thread_ids.second)
        CompletedForm.where(:_id.in => grouped.first[:individual_completed_forms].collect(&:id)).to_a.size.should == 2
      end
    end
  end
end
