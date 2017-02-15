require 'spec_helper'

describe Interactions::Alert do
  context "#self.export_header" do
    subject { Interactions::Alert.export_header }

    it { should be_a Array }
  end

  context "#self.export_header" do
    subject { Interactions::Alert.export_fields }

    it { should be_a Array }
  end

  context "with a reviewer named Jon Jones" do
    before do
      subject.reviewed_by = Fabricate(:user, :first_name => 'Jon', :last_name => 'Jones')
    end

    its(:reviewed_by_name) { should == 'Jon Jones' }
  end

  context "with no reviewer" do
    before do
      subject.stub(:reviewed_by) { nil }
    end

    its(:reviewed_by_name) { should == nil }
  end
end
