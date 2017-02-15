require 'spec_helper'

describe Institution do
  context "searching" do
    before(:each) do
      Fabricate(:institution, :name => "Foo School")
      Fabricate(:institution, :name => "Bar School")
      Fabricate(:institution, :name => "Foobar School")
    end

    it "searches starting from the beginning of the string" do
      Institution.search("foo").to_a.should have(2).instititions
    end

    it "searches in the middle of the string" do
      Institution.search("scho").to_a.should have(3).instititions
    end

    it "only searches after word boundaries" do
      Institution.search("bar").to_a.should have(1).institition
    end
  end

  context "associating with people" do
    before(:each) do
      @school = Fabricate(:school, :name => "Foo School")
      @recruit1 = Fabricate(:baseball_recruit, :school => @school)
      @recruit2 = Fabricate(:baseball_recruit, :school => @school)
      @recruit3 = Fabricate(:baseball_recruit)
    end

    it "returns associated recruits" do
      @school.recruits.to_a.should have(2).recruits
    end
  end

  context "scoping associated recruits on program" do
    before(:each) do
      @school = Fabricate(:school, :name => "Foo School")
      @program1 = Fabricate(:program)
      @program2 = Fabricate(:program)

      @recruit = Fabricate(:baseball_recruit,
        :school => @school, :program => @program1)
    end

    it "returns the recruit associated with the specified program" do
      recruits = @school.recruits_for_program(@program1).to_a

      recruits.should have(1).recruit
    end

    it "doesn't return the recruit associated with a different program" do
      recruits = @school.recruits_for_program(@program2).to_a

      recruits.should be_empty
    end

    it "returns recruits associated with clubs" do
      @club = Fabricate(:club)
      @recruit.club = @club
      @recruit.save

      recruits = @club.recruits_for_program(@program1).to_a
      recruits.should have(1).recruit
    end
  end

  context "assigning coaches" do
    before(:each) do
      @school = Fabricate(:school, :name => "Foo School")
      @program1 = Fabricate(:program)
      @program2 = Fabricate(:program)

      @program1coach1 = Fabricate(:user, :programs => [@program1])
      @program1coach2 = Fabricate(:user, :programs => [@program1])
      @program2coach1 = Fabricate(:user, :programs => [@program2])
      @program2coach2 = Fabricate(:user, :programs => [@program2])
    end

    it 'update the list of coaches assigned to the institution' do
      @school.set_coach_ids_for_program [@program1coach1.id, @program1coach2.id], @program1
      @school.user_ids.should =~ [@program1coach1.id, @program1coach2.id]
    end

    it 'only changes the coaches that belong to the given program' do
      @school.user_ids = [@program1coach1.id]
      @school.set_coach_ids_for_program [@program2coach1.id], @program2
      @school.user_ids.should =~ [@program1coach1.id, @program2coach1.id]
    end

    it "doesn't let people assign coaches outside the program" do
      @school.set_coach_ids_for_program [@program2coach1.id, @program1coach1.id], @program2
      @school.user_ids.should =~ [@program2coach1.id]
    end
  end
end
