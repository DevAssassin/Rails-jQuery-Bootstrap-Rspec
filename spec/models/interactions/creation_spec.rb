require 'spec_helper'

describe Interactions::Creation do
  context "#self.export_header" do
    subject { Interactions::Creation.export_header }

    it { should be_a Array }
  end

  context "#self.export_header" do
    subject { Interactions::Creation.export_fields }

    it { should be_a Array }
  end

  its(:interaction_name) { should be_a String }

  context 'person is a Recruit' do
    before do
      recruit = Fabricate(:recruit)
      subject.person = recruit
    end

    its(:recruit) { should be_a Recruit }
  end

  context 'person is not a Recruit' do
    before do
      alumnus = Fabricate(:alumnus)
      subject.person = alumnus
    end

    its(:recruit) { should == nil }
  end
end
