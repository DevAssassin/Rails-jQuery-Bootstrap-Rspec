require 'spec_helper'

describe Interactions::TaskComplete do
  let(:form) { Fabricate(:filled_in_form_with_task) }
  let(:task) { form.task }
  let(:completed_form) { form.submit!; form.completed_forms.first }
  let(:interactions) { completed_form; Interactions::TaskComplete.all.to_a }

  context "#self.export_header" do
    subject { Interactions::TaskComplete.export_header }

    it { should be_a Array }
  end

  context "#self.export_header" do
    subject { Interactions::TaskComplete.export_fields }

    it { should be_a Array }
  end

  its(:interaction_name) { should be_a String }

  it "creates an interaction when task is completed" do
    interactions.should have(1).thing
  end

  it "references associated task info and completed_form" do
    interaction = interactions.last

    interaction.task.should == task
    interaction.task_name.should == task.name
    interaction.due_at.should == task.due_at
    interaction.person.should == completed_form.assignee
    interaction.completed_form.should == completed_form
  end

  it "is account-level" do
    interactions.last.program.should be_nil
  end

  context "program-level" do
    let(:form) { Fabricate(:filled_in_form_with_task, :task => Fabricate(:task, :program => Fabricate(:program))) }

    it "is program-level, like task" do
      interactions.last.program_id.should_not be_nil
      interactions.last.program_id.should == task.program_id
    end
  end
end
