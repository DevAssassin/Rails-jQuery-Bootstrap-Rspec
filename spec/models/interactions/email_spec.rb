require 'spec_helper'

describe Interactions::Email do
  context "#self.export_header" do
    subject { Interactions::Email.export_header }

    it { should be_a Array }
  end

  context "#self.export_header" do
    subject { Interactions::Email.export_fields }

    it { should be_a Array }
  end

  context "no token has been assigned yet" do
    before do
      subject.token = nil
    end

    context 'after running #assign_token' do
      before do
        subject.assign_token
      end

      its(:token) { should_not be_blank }
    end
  end

  context "it has no open events" do
    before do
      subject.events = []
    end

    its(:status) { should be_nil }
  end

  context "it has an opened event" do
    before do
      subject.events = [EmailEvent.new(:event => 'open')]
    end

    its(:status) { should == "Opened" }
  end
end
