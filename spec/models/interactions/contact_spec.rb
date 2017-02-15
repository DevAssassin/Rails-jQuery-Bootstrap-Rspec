require 'spec_helper'

describe Interactions::Contact do
  it { should validate_presence_of(:contact_type).with_message("You must make a selection.") }

  context "#self.export_header" do
    subject { Interactions::Contact.export_header }

    it { should be_a Array }
  end

  context "#self.export_header" do
    subject { Interactions::Contact.export_fields }

    it { should be_a Array }
  end

  context 'contact_type is Contact and Evaluation' do
    before do
      subject.contact_type = 'Contact and Evaluation'
    end

    its(:interaction_name) { should == 'Contact/Eval' }
  end
end

