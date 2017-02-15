require 'spec_helper'

describe PeopleImport do

  it { should validate_presence_of :person_type }

  context "processing import" do
    let(:filename) { "#{Rails.root}/tmp/import.csv" }

    let(:csv) do
    end

    let(:program) { Fabricate(:baseball_program) }

    let(:import) do
      Fabricate(
        :people_import,
        :file => File.new(filename),
        :person_type => 'Recruit',
        :actions => ["first_name","last_name","email","","insert_into_comment"],
        :program => program,
        :user => Fabricate(:user)
      )
    end

    before(:each) do
      CSV.open(filename, "wb") do |csv|
        csv << ["FName", "LName", "E-Mail", "School", "Notes","Counselor Name","Counselor Phone", "Street Address", "City", "State", "Country", "Zip Code"]
        csv << ["Recruit", "Jones","rjones@recruit.local","UM","Test","Mr. Larry","123-456-7890", "5057 Woodward Avenue", "Detroit", "Michigan", "United States of America", "48120"]
        csv << ["Recruit2", "Jones2","r2jones2@recruit.local","MSU","Test2","Mr. Davis","123-456-7890", "21 Jump Streeet", "Ann Arbor", "MI", "USA", "49999"]
      end
    end

    after(:each) do
      File.delete(filename)
    end

    it "creates people in import program" do
      import.execute
      Person.last.program.should == program
    end

    it "sets importable fields" do
      import.execute
      r = Recruit.last
      r.first_name.should == "Recruit2"
      r.last_name.should == "Jones2"
      r.email.should == "r2jones2@recruit.local"
    end

    it "won't create recruit from headers" do
      import.execute
      Recruit.where(:first_name => "FName", :last_name => "LName").count.should == 0
    end

    it "creates coach when person type is coach" do
      import.person_type = 'Coach'
      import.execute
      Coach.last.email.should == "r2jones2@recruit.local"
      Coach.last.coach.should be_true
    end

    it "creates staff when person type is staff" do
      import.person_type = 'Staff'
      import.execute
      Coach.last.email.should == "r2jones2@recruit.local"
      Coach.last.coach.should be_false
    end

    it "creates rostered player when person type is player" do
      import.person_type = 'Player'
      import.execute
      RosteredPlayer.last.email.should == "r2jones2@recruit.local"
    end

    it "creates parent when person type is parent" do
      import.person_type = 'Parent'
      import.execute
      Person.last.email.should == "r2jones2@recruit.local"
      Person.last.parent.should be_true
    end

    it "creates alumni when person type is alumni" do
      import.person_type = 'Alumni'
      import.execute
      Person.last.email.should == "r2jones2@recruit.local"
      Person.last.alumnus.should be_true
    end

    it "creates donor when person type is donor" do
      import.person_type = 'Donor'
      import.execute
      Person.last.email.should == "r2jones2@recruit.local"
      Person.last.donor.should be_true
    end

    it "creates baseball recruit when person type is recruit" do
      import.person_type = 'Recruit'
      import.execute
      Recruit.last.email.should == "r2jones2@recruit.local"
      Recruit.last._type.should == "Sport::Baseball"
    end

    it "appends columns when same field is selected" do
      import.actions += ["counselor_info","counselor_info"]
      import.execute
      Recruit.last.counselor_info.should == "Mr. Davis\n123-456-7890"
    end

    it "imports the address" do
      import.actions += ["", "", "street", "city", "state", "country", "post_code"]
      import.execute
      addy = Recruit.last.address
      addy.street.should == "21 Jump Streeet"
      addy.city.should == "Ann Arbor"
      addy.state.should == "Michigan"
      addy.country.should == "United States of America"
      addy.post_code.should == "49999"
    end

    it "sends emails with status updates" do
      ActionMailer::Base.deliveries = []
      import.execute
      ActionMailer::Base.deliveries.should have(2).emails
    end
  end
end
