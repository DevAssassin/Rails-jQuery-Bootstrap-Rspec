require 'spec_helper'
include CarrierWave::Test::Matchers

describe Recruit do
  it "embeds an address" do
    r = Fabricate(:recruit)

    r.build_address(:street => 'foo')

    r.address.street.should == 'foo'
  end

  context "parsing a list of emails" do
    it "parses list on newlines and commas" do
      emails = "1@example.com
      2@example.com, 3@example.com"
      parsed_emails = Recruit.parse_emails(emails)
      parsed_emails.size.should == 3
    end

    it "strips leading and trailing whitespace from emails" do
      emails = "  hello@example.com  ,    goodbye@example.com "
      parsed_emails = Recruit.parse_emails(emails)
      parsed_emails.first.should == "hello@example.com"
      parsed_emails.second.should == "goodbye@example.com"
    end
  end

  context "creating from a list of emails" do
    before :each do
      @program = Fabricate(:program)
      @emails = ["hello@example.com"]
    end

    it "creates if recruit doesn't exist and adds program" do
      Recruit.create_from_emails(@emails, @program)
      @program.recruits.size.should == 1
      recruit = @program.recruits.first
      recruit.email.should == 'hello@example.com'
    end

    it "finds if recruit exists and adds program" do
      recruit = Fabricate(:baseball_recruit, :email => "hello@example.com", :program => @program)
      Recruit.create_from_emails(@emails, @program)
      @program.recruits.size.should == 1
      @program.recruits.first.should == recruit
    end

    it "does not find recruit if they are from a different program" do
      other_program = Fabricate(:program)
      recruit = Fabricate(:baseball_recruit, :email => "hello@example.com", :program => other_program)
      Recruit.create_from_emails(@emails, @program)
      @program.recruits.size.should == 1
      @program.recruits.first.should_not == recruit
    end
  end

  context "with interactions" do
    before(:each) do
      @recruit = Fabricate(:recruit)
      @interaction = Fabricate(:letter_interaction)
      @recruit.interactions << @interaction
    end

    it "returns a list of latest interactions" do
      @recruit.latest_interactions.should include(@interaction)
    end
  end

  context "ratings" do
    before(:each) do
      @john = Fabricate(:user)
      @recruit = Fabricate(:recruit)

      @recruit.rate(@john, 7)
    end

    it "allows one person to rate a recruit" do
      @recruit.rating(@john).should == 7
    end

    it "doesn't count ratings of zero" do
      @recruit.rate(@john, 0)

      @recruit.rating(@john).should be_nil
    end

    context "two people rating a recruit" do
      before(:each) do
        @jane = Fabricate(:user)

        @recruit.rate(@jane, 5)
        @recruit.save
      end

      it "calculates an average of the ratigs" do
        @recruit.avg_rating.should == 6
      end
    end
  end

  context "assigned coaches" do
    before(:each) do
      @john = Fabricate(:user)
      @jane = Fabricate(:user)
      @recruit = Fabricate(:recruit)
    end

    it "assigns a single coach" do
      @recruit.add_watchers([@john])

      @recruit.watchers.should include(@john)
    end

    it "assigns multiple coaches" do
      @recruit.add_watchers([@john, @jane])

      @recruit.watchers.should include(@john)
      @recruit.watchers.should include(@jane)

      # It should not duplicate an already-existing coach
      @recruit.add_watchers([@john])
      @recruit.watchers.should == [@john, @jane]
    end

    it "allows access via coaches" do
      @recruit.add_watchers([@john])
      @recruit.save

      @john.coached_recruits.should include(@recruit)
    end

    it "allows mass setting of coach_ids when there are spaces" do
      @recruit.watcher_ids = [@john.id.to_s, ""]

      @recruit.save

      @recruit.reload

      @recruit.watchers.should include(@john)
    end
  end

  context "creation interactions" do
    before(:each) do
      @recruit = Fabricate(:recruit)
    end

    it "creates an interaction" do
      @recruit.add_creation_interaction

      @recruit.interactions.first.should be_kind_of(Interactions::Creation)
    end
  end

  context "assigning boards" do
    before(:each) do

      @recruit = Fabricate(:baseball_recruit, :program => Fabricate(:program))
      @board1 = Fabricate(:recruit_board, :program => @recruit.program)
    end

    it "assigns a recruit to the only board" do
      @recruit.assign_board_ids([@board1.id])
      @board1.reload

      @board1.recruits.should include(@recruit)
    end

    it "ignores bogus board ids" do
      lambda {
        @recruit.assign_board_ids([''])
      }.should_not raise_error
    end

    context "multiple boards" do
      before(:each) do
        @board2 = Fabricate(:recruit_board, :program => @recruit.program)
      end

      it "removes the recruit from existing boards when reassigned" do
        @recruit.assign_board_ids([@board1.id])
        @board1.reload
        @board2.reload
        @recruit.assign_board_ids([@board2.id])
        @board1.reload
        @board2.reload

        @board2.recruits.should include(@recruit)
        @board1.recruits.should_not include(@recruit)
      end
    end
  end


  context "uploading a profile photo" do
    before(:each) do
      @recruit = Fabricate(:recruit)
      PhotoUploader.enable_processing = true
      @uploader = PhotoUploader.new(@recruit, :photo)
      @uploader.store!(File.open("#{Rails.root}/app/assets/images/test_photo.png"))
    end

    after do
      PhotoUploader.enable_processing = false
    end

    context 'the thumb version' do
      it "should scale down the uploaded image to limit within 100 by 100 pixels maintaining aspect-ratio" do
        @uploader.thumb.should be_no_larger_than(100,100)
        @recruit.photo_filename.should == nil
        @recruit.update_attributes(:photo => @uploader)
        @recruit.photo_filename.should == "test_photo.png"
      end
    end
  end

  context "deleting recruit" do
    before(:each) do
      @recruit = Fabricate(:recruit, :program => Fabricate(:program))
      @board  = Fabricate(:recruit_board, :program => @recruit.program)
    end

    it "soft-deletes recruit successfully" do
      Recruit.count.should==1
      @recruit.delete
      Recruit.count.should==0
      Recruit.deleted.count.should==1
    end

    it "removes it from board" do
      @recruit.assign_board_ids([@board.id])
      @board.reload
      @board.recruits.should include(@recruit)

      @recruit.delete
      @board.reload
      @board.recruits.should_not include(@recruit)
    end

    it "creates a deletion interaction" do
      @recruit.delete
      @recruit.add_deletion_interaction
      @recruit.interactions.last.should be_kind_of(Interactions::Deletion)
    end

    it "followed by restoring" do
      Recruit.count.should==1
      @recruit.delete
      Recruit.count.should==0
      Recruit.deleted.count.should==1

      @recruit.restore
      Recruit.count.should==1
      Recruit.deleted.count.should==0
    end
  end

  describe "#merge_recruit(slave_recruit)" do
    before(:each) do
      @slave_recruit = Fabricate(:baseball_recruit, :program => Fabricate(:program))
      @master_recruit = Fabricate(:baseball_recruit, :program => @slave_recruit.program)
    end

    it "should merge the address" do
      @slave_recruit.create_address(:street => 'foo')
      @master_recruit.merge_recruit(@slave_recruit)

      @master_recruit.address.street.should == "foo"
    end

    it "should merge all recruit boards" do
      @board1 = Fabricate(:recruit_board, :program => @slave_recruit.program)
      @board2 = Fabricate(:recruit_board, :program => @slave_recruit.program)

      @slave_recruit.assign_board_ids([@board1.id])
      @master_recruit.assign_board_ids([@board2.id])

      @master_recruit.merge_recruit(@slave_recruit)
      @board1.reload
      @board2.reload
      @master_recruit.reload

      @board1.recruits.should include(@master_recruit)
      @master_recruit.recruit_boards.should include(@board1)
      @master_recruit.recruit_boards.should include(@board2)
    end

    it "should merge all coaches" do
      @coach1 = Fabricate(:user)
      @coach2 = Fabricate(:user)

      @slave_recruit.add_watchers([@coach1])
      @master_recruit.add_watchers([@coach2])

      @master_recruit.merge_recruit(@slave_recruit)

      @master_recruit.watchers.should include(@coach1)
      @master_recruit.watchers.should include(@coach1)
    end

    it "should merge all interactions" do
      phone_interaction = Fabricate(:phone_call_interaction)
      letter_interaction = Fabricate(:letter_interaction)
      comment_interaction = Fabricate(:comment_interaction)

      @master_recruit.interactions << phone_interaction
      @slave_recruit.interactions << letter_interaction
      @slave_recruit.interactions << comment_interaction

      @master_recruit.merge_recruit(@slave_recruit)

      @master_recruit.interactions.count.should == 3

    end

    it "should merge with fields from master taking precedence" do
      email = @slave_recruit.email
      @slave_recruit.update_attributes(:fathers_email => "foo@bar.com",
      :fathers_name => "foo bar",
      :hobbies => "football",
      :nickname => "nick");

      @master_recruit.merge_recruit(@slave_recruit)

      @master_recruit.email.should_not == email

      @master_recruit.fathers_name.should == "foo bar"
      @master_recruit.fathers_email.should == "foo@bar.com"
      @master_recruit.hobbies.should == "football"
      @master_recruit.nickname.should == "nick"
    end

    it "should delete the slave recruit" do
      @master_recruit.merge_recruit(@slave_recruit)

      @slave_recruit.destroyed?.should == true
    end

    context "merging profile photo" do
      before(:each) do
        PhotoUploader.enable_processing = true
        @uploader1 = PhotoUploader.new(@slave_recruit, :photo)
        @uploader2 = PhotoUploader.new(@master_recruit, :photo)
        @uploader1.store!(File.open("#{Rails.root}/app/assets/images/test_photo.png"))
        @uploader2.store!(File.open("#{Rails.root}/app/assets/images/default_photo.jpeg"))
      end

      after do
        PhotoUploader.enable_processing = false
      end

      it "should merge the profile photo if empty" do
        @slave_recruit.update_attributes(:photo => @uploader1)

        @master_recruit.merge_recruit(@slave_recruit)

        @master_recruit.photo_filename.should == "test_photo.png"
      end

      it "should not merge the profile photo if not empty" do
        @slave_recruit.update_attributes(:photo => @uploader1)
        @master_recruit.update_attributes(:photo => @uploader2)

        @master_recruit.merge_recruit(@slave_recruit)

        @master_recruit.photo_filename.should_not == "test_photo.png"
      end
    end
  end

  context "when calculating class from graduation year" do
    before(:all) do
      @__old_zone = Time.zone

      Time.zone = "Istanbul"
    end

    after(:all) do
      Time.zone = @__old_zone
    end

    context "on a senior" do
      let(:recruit) { Fabricate(:baseball_recruit, graduation_year: '2012') }

      it { recruit.school_class(Time.parse("2012-01-15 00:00:00 EST")).should == :senior }
      it { recruit.school_class(Time.parse("2011-11-15 00:00:00 EST")).should == :senior }
      it { recruit.school_class(Time.parse("2011-08-01 00:00:00 EDT")).should == :senior }
      it { recruit.school_class(Time.parse("2011-07-31 23:59:59 EDT")).should_not == :senior }
    end

    context "on a junior" do
      let(:recruit) { Fabricate(:baseball_recruit, graduation_year: '2013') }

      it { recruit.school_class(Time.parse("2012-01-15 00:00:00 EST")).should == :junior }
      it { recruit.school_class(Time.parse("2011-11-15 00:00:00 EST")).should == :junior }
      it { recruit.school_class(Time.parse("2011-08-01 00:00:00 EDT")).should == :junior }
      it { recruit.school_class(Time.parse("2011-07-31 23:59:59 EDT")).should_not == :junior }
    end

    context "on a sophomore" do
      let(:recruit) { Fabricate(:baseball_recruit, graduation_year: '2014') }

      it { recruit.school_class(Time.parse("2012-01-15 00:00:00 EST")).should == :sophomore }
      it { recruit.school_class(Time.parse("2011-11-15 00:00:00 EST")).should == :sophomore }
      it { recruit.school_class(Time.parse("2011-08-01 00:00:00 EDT")).should == :sophomore }
      it { recruit.school_class(Time.parse("2011-07-31 23:59:59 EDT")).should_not == :sophomore }
    end

    context "on a sophomore" do
      let(:recruit) { Fabricate(:baseball_recruit, graduation_year: '2015') }

      it { recruit.school_class(Time.parse("2012-01-15 00:00:00 EST")).should == :freshman }
      it { recruit.school_class(Time.parse("2011-11-15 00:00:00 EST")).should == :freshman }
      it { recruit.school_class(Time.parse("2011-08-01 00:00:00 EDT")).should == :freshman }
      it { recruit.school_class(Time.parse("2011-07-31 23:59:59 EDT")).should_not == :freshman }
    end
  end

  describe "#as_json" do
    let(:recruit) { Fabricate(:recruit) }

    context "with a rules engine account" do
      it "returns the number of calls remaining" do
        recruit.as_json(rules_engine: true)[:calls_remaining].should == 0
      end
    end

    context "without a rules engine account" do
      it "doesn't include the calls remaining" do
        recruit.as_json.keys.should_not include(:calls_remaining)
      end
    end

    pending "more json specs"
  end

  context "custom fields" do
    let(:recruit) { Fabricate(:recruit, :program => Fabricate(:program_with_custom_fields)) }
    let(:recruit2) { Fabricate(:recruit) }
    context "when retrieving" do
      it "returns all custom fields" do
        recruit.custom_fields.count.should == 3
        recruit2.custom_fields.count.should == 0
      end
      it "can tell if there are custom fields" do
        recruit.has_custom_fields?.should be_true
        recruit2.has_custom_fields?.should be_false
      end
      [:academic,:athletic,:personal].each do |section|
        it "can tell if there are custom #{section} fields" do
          recruit.has_custom_fields?(section).should be_true
          recruit2.has_custom_fields?(section).should be_false
        end
        it "returns custom #{section} fields" do
          custom_fields = recruit.custom_fields(section)
          custom_fields.count.should == 1
          custom_fields.first.section.should == section.to_s
          recruit2.custom_fields(section).count.should == 0
        end
      end
    end

    context "when returning a value for a field" do
      let(:name) { recruit.custom_fields.first.name.to_sym }
      it "returns blank string if there isn't a field value" do
        recruit.send(name).should == ""
      end
      it "returns value if there is a field value" do
        "This is a test value.".tap do |value|
           recruit[name] = value
           recruit.save
           recruit.reload.send(name).should == value
        end
      end
      it "doesn't break method missing" do
        lambda {
          recruit.blah_blah_blah
        }.should raise_error
      end
    end
  end
end
