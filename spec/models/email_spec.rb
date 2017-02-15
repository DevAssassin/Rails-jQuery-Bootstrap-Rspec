require 'spec_helper'

describe Email do

# TODO: Make this pass
#  context "saving" do
#    it "should fail when trying to save email without recipients" do
#      @email = Fabricate(:email)
#      @email.save
#      @email.errors[:recipients].should include("Please add at least one recipient before sending")
#    end
#  end

  context "body is not parsable by Mustache" do
    before do
      subject.body = "Hi, I am {{not valid"
    end

    it { should have(1).error_on(:body) }
  end

  context "rendering a template" do
    before(:each) do
      @email = Fabricate(:email)
      @email.body = 'baz'
    end

    it "renders the content into the template" do
      @email.template = Fabricate(:email_template, :source => "foo{{{content}}}bar")

      @email.templated_body_for.should include("foo")
      @email.templated_body_for.should include("baz")
    end

    it "renders without a template" do
      @email.templated_body_for.should include("baz")
    end
  end

  context "merging fields" do
    before(:each) do
      @email = Fabricate(:email) do
        body '{{first_name}}Bob {{{invite_link}}}'
        recipients [Fabricate(:baseball_recruit, :first_name => "Joe")]
      end
    end

    it "merges in first name of the recipient" do
      @email.merge(@email.recipients.first).should include("JoeBob")
    end

    it "merges in the invite_link of the recipient" do
      @email.merge(@email.recipients.first).should include(@email.recipients.first.invite_link)
    end
  end

  context "merging task form fields" do
    before :each do
      @email = Fabricate(:email) do
        task! Fabricate(:task_with_form_group)
        body '{{first_name}} {{{task_form_link}}}'
        recipients { |e| [ e.task.assignee ] }
      end
    end

    it "merges task_form_link for recipient" do
      recipient = @email.recipients.first
      @email.merge(recipient).should include(@email.task_form_link(recipient))
    end
  end

  context "copying users" do
    before(:each) do
      @email = Fabricate(:email) do
        body '{{first_name}}Bob {{{invite_link}}}'
        from Fabricate(:user, :first_name => 'Sam')
      end
    end

    it "doesn't merge fields when sending to users" do
      @email.merge(@email.recipients.first).should_not include("Joe")
    end

    it "preserves mustache tags" do
      @email.merge(@email.recipients.first).should include("{{first_name}}")
    end

    it "doesn't save an interaction" do
      @email.send_email

      Interaction.all.to_a.should be_empty
    end
  end

  context "recipients without emails" do
    before(:each) do
      @email = Fabricate(:email) do
        body '{{first_name}}Bob {{{invite_link}}}'
        recipients [Fabricate(:recruit, :first_name => "Joe", :email => "")]
        from Fabricate(:user, :first_name => 'Sam')
      end

      ActionMailer::Base.deliveries = []
    end

    it "doesn't save an interaction" do
      @email.send_email

      Interaction.all.to_a.should be_empty
    end

    it "doesn't send an email" do
      @email.send_email

      ActionMailer::Base.deliveries.should be_empty
    end
  end

  context "schedule sending" do
    before :each do
      @email = Fabricate(:email) do
        recipients {[Fabricate(:recruit, :email => 'hi@example.com')]}
        from Fabricate(:user)
      end
      @deliveries = ActionMailer::Base.deliveries
    end

    it "sends immediately by default" do
      lambda {
        @email.schedule_or_send
      }.should change(@deliveries, :size).by(1)
    end

    it "allows sending in the future" do
      Delayed::Worker.delay_jobs = true
      @email.schedule = Schedule.new(:amount => 2, :unit => "days")
      lambda {
        @email.schedule_or_send
      }.should_not change(@deliveries, :size)

      lambda {
        Timecop.travel(1.day.from_now) do
          Email.send_scheduled_emails
        end
      }.should_not change(@deliveries, :size)

      lambda {
        Timecop.travel(2.days.from_now + 5.minutes) do
          Email.send_scheduled_emails
        end
      }.should change(@deliveries, :size).by(1)
      Delayed::Worker.delay_jobs = false
    end

    it "doesn't send email in #send_scheduled_emails if send_time is nil (backward compatibility)" do
      @email.send_time = nil
      @email.save!
      lambda {
        Email.send_scheduled_emails
      }.should_not change(@deliveries, :size)
    end

    context "a certain amount of time from now" do
      before :each do
        @email = Fabricate(:email) do
          recipients {[Fabricate(:recruit, :email => 'hi@example.com')]}
          from Fabricate(:user)
        end
      end

      it "allows sending in 1 day" do
        @email.schedule = {:amount => "1", :unit => "day"}
        @email.schedule_or_send
        @email.send_time.to_s.should == 1.day.from_now.to_s
      end

      it "allows sending in 2 weeks" do
        @email.schedule = {:amount => "2", :unit => "weeks"}
        @email.schedule_or_send
        @email.send_time.to_s.should == 2.weeks.from_now.to_s
      end

      it "allows sending in 1 month" do
        @email.schedule = {:amount => "1", :unit => "months"}
        @email.schedule_or_send
        @email.send_time.to_s.should == 1.month.from_now.to_s
      end
    end

    context "a certain amount of time before some date" do
      before :each do
        @email = Fabricate(:email) do
          recipients {[Fabricate(:recruit, :email => 'hi@example.com')]}
          from Fabricate(:user)
        end
        @some_date = 2.months.from_now
      end

      it "allows sending 1 day before" do
        @email.schedule = {:amount => "1", :unit => "day", :relative_to => @some_date, :relative_direction => :before}
        @email.schedule_or_send
        @email.send_time.to_s.should == (@some_date - 1.day).to_s
      end

      it "allows sending 1 week before" do
        @email.schedule = {:amount => "1", :unit => "week", :relative_to => @some_date, :relative_direction => :before}
        @email.schedule_or_send
        @email.send_time.to_s.should == (@some_date - 1.week).to_s
      end

      it "allows sending 1 month before" do
        @email.schedule = {:amount => "1", :unit => "month", :relative_to => @some_date, :relative_direction => :before}
        @email.schedule_or_send
        @email.send_time.to_s.should == (@some_date - 1.month).to_s
      end
    end
  end
  context "scheduling with delayed job enabled" do
    before :each do
      Delayed::Worker.delay_jobs = true
      @email = Fabricate(:single_email)
      @now = Time.now
    end

    after :each do
      Delayed::Worker.delay_jobs = false
    end

    it "schedules delivery using mongoid job" do
      @email.schedule = {:amount => "2", :unit => "week", :relative_to => @now, :relative_direction => :after}
      @email.schedule_or_send
      @email.reload.job.run_at.should > (@now + 13.days)
    end
  end
end
