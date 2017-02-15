require 'spec_helper'

describe Interactions::TaskAssign do
  let(:task) { Fabricate(:task_with_form_group) }
  let(:interactions) { task; Interactions::TaskAssign.all.to_a }

  context "#self.export_header" do
    subject { Interactions::TaskAssign.export_header }

    it { should be_a Array }
  end

  context "#self.export_header" do
    subject { Interactions::TaskAssign.export_fields }

    it { should be_a Array }
  end

  its(:interaction_name) { should be_a String }

  it "creates an interaction when a task is assigned" do
    interactions.size.should == task.assignments.size
    interactions.collect(&:person).should == task.assignees
  end

  it "references associated task info" do
    interaction = interactions.last

    interaction.task.should == task
    interaction.task_name.should == task.name
    interaction.due_at.should == task.due_at
    interaction.user.should_not be_nil
    interaction.user.should == task.user
  end

  it "is account-level" do
    interactions.last.program.should be_nil
  end

  context "program-level" do
    let(:task) { Fabricate(:task_with_form_group, :program => Fabricate(:program)) }

    it "is program-level, like task" do
      interactions.last.program_id.should_not be_nil
      interactions.last.program_id.should == task.program_id
    end
  end
end
