require 'spec_helper'

describe MassInteraction do
  context "when creating a mass interaction" do

    before :each do
      @user = Fabricate(:user)
      @p1 = Fabricate(:person)
      @p2 = Fabricate(:baseball_recruit)
    end

    it "should accept a string of people ids" do
      i = MassInteraction.new
      i.person_ids_string = "#{@p1.id.to_s}, #{@p2.id.to_s}"
      i.person_ids.should include(@p1.id)
      i.person_ids.should include(@p2.id)
    end

    it "should convert array of people ids into string" do
      i = MassInteraction.new
      i.person_ids = [@p1.id,@p2.id]
      i.person_ids_string.should == "#{@p1.id.to_s}, #{@p2.id.to_s}"
    end

    it "should accept person_ids in constructor" do
      i = MassInteraction.new(:person_ids => [@p1.id, @p2.id])
      i.people.should include(@p1)
      i.people.should include(@p2)
    end

    it "should use person_ids to fetch people" do
      i = MassInteraction.new
      i.person_ids = [@p1.id,@p2.id]
      i.people.should include(@p1)
      i.people.should include(@p2)
    end

    it "should accept people objects" do
      i = MassInteraction.new
      i.people = [@p1,@p2]
      i.people.should include(@p1)
      i.people.should include(@p2)
    end

    it "should not create an interaction if original is not valid" do
      i = MassInteraction.new(:person_ids => [@p1.id,@p2.id])
      i.user = @user
      i.original = Interactions::Contact.new(:text => "Test")
      i.save.should == false
      i.interactions.should be_empty
      i.errors.should_not be_empty
    end

    it "should not create an interaction if no people are passed" do
      i = MassInteraction.new
      i.user = @user
      i.original = Interactions::Contact.new(:text => "Test")
      i.save.should == false
      i.interactions.should be_empty
      i.errors.should_not be_empty
    end

    it "should create an interaction for each person" do
      i = MassInteraction.new(:person_ids => [@p1.id,@p2.id])
      i.user = @user
      i.original = Interactions::Contact.new(:text => "Test", :contact_type => "Contact")
      i.save

      i.interactions.each { |i| i.user.should == @user }
      i.interactions.should include(@p1.reload.interactions.last)
      i.interactions.should include(@p2.reload.interactions.last)
    end

  end
end
