require 'spec_helper'

describe Report do

  it { should validate_presence_of :name }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :interaction_type }

  context "dates" do
    #TODO: figure out how to make this more concise

    it_behaves_like "hot date", :start_date do
      let(:dateable) { Report.new }
    end

    it_behaves_like "hot date", :end_date do
      let(:dateable) { Report.new }
    end

  end

  context "creating report datasets" do
    let(:person) { Fabricate(:recruit) }
    let(:program) { person.program }

    before(:each) do
      @__old_zone = Time.zone
      Time.zone = "Kathmandu"
      @report = Fabricate(:comment_report, :program => program,
        :start_date => Kronic.parse("March 1, 2011"),
        :end_date => Kronic.parse("March 31, 2011")
      )

      #TODO figure out why program_id is require and program alone doesn't work
      @comment1 = Fabricate(:comment_interaction,
        :interaction_time => Time.parse("2011-03-05 21:00 +0545"),
        :person => person)
      @comment2 = Fabricate(:comment_interaction,
        :interaction_time => Time.parse("2011-02-05 21:00 +0545"),
        :person => person)
    end

    after(:each) do
      Time.zone = @__old_zone
    end

    it "out of comments" do
      @report.records.to_a.should =~ [@comment1]
    end

    it "outputs csvs" do
      @report.to_csv.split("\n").should have(2).lines
    end

    it "includes the end date" do
      report = Fabricate(:comment_report, :program => program,
        :start_date => Kronic.parse("March 1, 2011"),
        :end_date => Kronic.parse("March 5, 2011")
      )

      report.records.to_a.should =~ [@comment1]
    end

    it "works without the end date" do
      report = Fabricate(:comment_report, :program => program,
        :start_date => Kronic.parse("March 1, 2011"),
        :end_date => nil
      )

      report.records.to_a.should =~ [@comment1]
    end

    context "scoped by users" do
      before(:each) do
        @report.reported_user = @comment1.user
        @comment3 = Fabricate(:comment_interaction,
          :interaction_time => Kronic.parse("March 5, 2011"),
          :person => person, :user => Fabricate(:user))
      end

      it "only returns records for the specified user" do
        @report.records.to_a.should =~ [@comment1]
      end
    end
  end

  context "account and/or program level reports" do
    let!(:program_person) { Fabricate(:person, :program => Fabricate(:program)) }
    let!(:account_person) { Fabricate(:person, :account => program_person.account) }
    let!(:program) { program_person.program }
    let!(:account) { program_person.account }
    let!(:report) { Fabricate(:creation_report, :account => account, :program => program, :start_date => Kronic.parse("March 1, 2011"), :end_date => Kronic.parse("March 31, 2011")) }
    let!(:account_interaction) { Fabricate(:creation_interaction, :interaction_time => Time.parse("2011-03-05 21:00 +0545"), :person => account_person) }
    let!(:program_interaction) { Fabricate(:creation_interaction, :interaction_time => Time.parse("2011-03-11 21:00 +0545"), :person => program_person) }
    let!(:other_interaction1) { Fabricate(:creation_interaction, :interaction_time => Time.parse("2011-03-06")) }
    let!(:other_interaction2) { Fabricate(:creation_interaction, :interaction_time => Time.parse("2011-03-06"), :person => Fabricate(:recruit, :program => nil, :account => Fabricate(:account))) }

    it "return all interactions if interaction_scope blank" do
      report.interaction_scope = ''
      report.records.to_a.should =~ [account_interaction, program_interaction]
    end

    it "return account-level interactions if interaction_scope is account-level" do
      report.interaction_scope = 'Account'
      report.records.to_a.should =~ [account_interaction]
    end

    it "return program-level interactions if interaction_scope is program-level" do
      report.interaction_scope = 'Program'
      report.records.to_a.should =~ [program_interaction]
    end

    it "return program interactions if interaction_scope is a program id" do
      report.interaction_scope = program.id
      report.records.to_a.should =~ [program_interaction]
    end

    it "returns program level interactions at the account level" do
      report.program = nil
      report.interaction_scope = 'Program'
      report.records.to_a.should =~ [program_interaction]
    end
  end
end
