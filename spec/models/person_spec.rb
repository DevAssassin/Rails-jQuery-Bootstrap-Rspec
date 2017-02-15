require 'spec_helper'

describe Person do

  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }

  context "tags" do
    it "can add a string list of tags" do
      person = Fabricate(:person)

      person.program_tags = "foo, bar"
      person.save

      person.program_tags_array.should == %w{foo bar}
    end

    it "should ignore trailing commas" do
      person = Fabricate(:person)

      person.program_tags = "foo, bar, "
      person.save

      person.program_tags_array.should == %w{foo bar}
    end
  end

  context "dates" do
    it_behaves_like "hot date", :birthdate do
      let(:dateable) { Person.new }
    end
  end

  context "sorting" do
    it "creates sortable last name field" do
      @person = Fabricate(:baseball_recruit,:last_name=>" Roberts ")
      @person.save
      @person.sortable_name.should == "roberts #{@person.first_name.downcase}"
    end
  end

  context "children" do
    it "uses children_ids to link parents to children" do
      @child = Fabricate(:baseball_recruit)
      @parent = Fabricate(:person)
      @parent.children_ids << @child.id
      @parent.save

      @parent.children.should include @child
      @child.parents.should include @parent
      @child.children.should == []
    end

    it "can accept a string of ids to link parents to children" do
      @child1 = Fabricate(:baseball_recruit)
      @child2 = Fabricate(:soccer_recruit)
      @parent = Fabricate(:person)
      @parent.children_ids_string = "#{@child1.id.to_s}, #{@child2.id.to_s}"
      @parent.children_ids.count.should == 2
      @parent.save

      @parent.children.should include @child1
      @child1.parents.should include @parent
      @parent.children.should include @child2
      @child2.parents.should include @parent
    end

    it "won't fail if children_ids is nil" do
      @parent = Fabricate(:person)
      @parent.children_ids = nil
      @parent.save

      @parent.children.should == []
    end
  end

  context "when searching by account or program" do
    let(:account) { Fabricate(:account) }
    let(:program) { Fabricate(:program, :account => account) }
    let!(:person) { Fabricate(:person, :account => account, :program => program) }

    it "finds by account" do
      Person.where_account_or_program(account).first.should == person
    end

    it "finds by program" do
      Person.where_account_or_program(program).first.should == person
    end
  end

  context "generating csv" do
    context "from a Person" do
      let(:college) { Fabricate(:college, :name => 'Albion College')}
      let(:person) { Fabricate(:person, :gpa => 'gpagpagpa', :college => college) }

      it "exports the person's name" do
        person.to_csv.should =~ /#{person.first_name}/
      end

      it "doesn't export GPA" do
        person.to_csv.should_not =~ /gpa/
      end

      it "exports the person's college name" do
        person.to_csv.should include 'Albion College'
      end

      it 'should export the field names as human readables' do
        Person.csv_header.should include "First Name"
        Person.csv_header.should_not include 'first_name'
      end

      it 'should not start with ID' do #MS thinks any file that starts with ID is a SYLK file
        person.to_csv.should_not be_start_with 'ID'
        Person.csv_header.should_not be_start_with 'ID'
      end
    end

    context "from a Recruit" do
      let(:coach)  { Fabricate(:user, :first_name => 'Jim', :last_name => 'Beam')}
      let(:school) { Fabricate(:school, :name => 'Hamtramck High School')}
      let(:person) { Fabricate(:recruit, :gpa => 'gpagpagpa', :watchers => [coach], :school => school) }

      it "exports the GPA by default" do
        person.to_csv.should =~ /gpa/
      end

      it "doesn't export the GPA if Person-style export is requested" do
        person.to_csv(Person).should_not =~ /gpa/
      end

      it 'should export the recruit watchers' do
        person.to_csv.should include 'Jim'
        person.to_csv.should include 'Beam'
      end

      it 'should export the high school name' do
        person.to_csv.should include 'Hamtramck High School'
      end

      it 'should export the field names as human readables' do
        Recruit.csv_header.should include "Father's Name"
        Recruit.csv_header.should_not include 'fathers_name'
      end
    end
  end

  context "returning appropriate person subclasses" do
    it "returns coaches" do
      Person.person_subclass('coach').should == Coach
      Person.person_subclass('coaches').should == Coach
    end

    it "returns staff as coach" do
      Person.person_subclass('staff').should == Coach
    end

    it "returns rostered players" do
      Person.person_subclass('rostered_player').should == RosteredPlayer
      Person.person_subclass('rostered_players').should == RosteredPlayer
    end

    %w{ other others person people donor donors parent parents alumnus alumni }.each do |type|
      it "returns Person for #{type}" do
        Person.person_subclass(type).should == Person
      end
    end

    it "returns recruits if no program is specified" do
      Person.person_subclass('recruit').should == Recruit
      Person.person_subclass('recruits').should == Recruit
    end

    it "returns recruits of correct type if program is specified" do
      Person.person_subclass('recruit', Fabricate(:baseball_program)).should == Sport::Baseball
      Person.person_subclass('recruits', Fabricate(:baseball_program)).should == Sport::Baseball
    end
  end

  describe 'A person without a program_id' do
    subject { Fabricate(:person, :program_id => nil) }

    its(:conversion_types) { should_not include 'Recruit' }
  end

  describe 'A baseball recruit conversion types' do
    subject { Fabricate(:baseball_recruit).conversion_types }

    it { should be_a Array }
    it { should include 'Alumnus' }
    it { should include 'Recruit' }
    it { should_not include 'Sport::Baseball' }
    it { should_not include 'InstitutionCoach' }
    it { should_not include 'Counselor' }
  end

  describe '#conversion_type=' do
    it 'should make the right Sport for recruit' do
      prog = Fabricate(:basketball_program)
      person = Fabricate(:person, :program => prog)
      person.conversion_type = 'Recruit'
      person._type.should == 'Sport::Basketball'
    end
  end

  context "rendering json" do
    pending "write json specs"
  end
end
