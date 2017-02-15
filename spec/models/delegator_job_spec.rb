require 'spec_helper'

describe DelegatorJob do
  context "When executing" do
    let(:email) { Fabricate(:single_email, :schedule => Schedule.new) }
    let(:delegator) { DelegatorJob.new(email, :send_email) }
    let(:job) { Delayed::Backend::Mongoid::Job.new }
    context "immediately" do
      it "calls method on the delegated object" do
        Email.stub!(:find).and_return(email)
        email.should_receive(:send)
        delegator.perform
      end

      it "throws exception if delegated object not found" do
        email.destroy
        lambda {
          delegator.perform
        }.should raise_error
      end
    end
    context "at a later date" do
      it "saves mongoid job on the delegated object" do
        delegator.enqueue(job)
        Email.find(email.id).job.should == job
      end
    end
  end
end
