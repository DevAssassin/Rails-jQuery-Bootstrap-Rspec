require 'spec_helper'

describe Program do
  context "Notify recruit form" do
    before :each do
      @program = Fabricate(:program, :notify_recruit_form_string => 'hi@example.com, bye@example.com')
    end

    it "normalizes comma-separated string of email addresses" do
      @program.notify_recruit_form.should == ["hi@example.com", "bye@example.com"]
    end
  end

  context "Recruit boards" do
    before(:each) do
      @program = Fabricate(:program)
      @recruit_board = Fabricate(:recruit_board, :program => @program)
    end

    it "associates recruit boards and programs" do
      @recruit_board.program.should == @program
      @program.recruit_boards.should include(@recruit_board)
    end
  end

  context "different sports" do
    let(:program) { Fabricate(:program) }

    it "returns the sport class" do
      program.sport_class.should == Sport::Baseball
    end
  end

  context "coaches vs. staff" do
    before(:each) do
      @program = Fabricate(:baseball_program)
      @coach = Fabricate(:coach, :program => @program)
      @staff = Fabricate(:staff, :program => @program)
    end

    it "returns everyone for staff" do
      @program.staff.to_a.should =~ [@coach, @staff]
    end

    it "returns only coaches for coaches" do
      @program.coaches.to_a.should =~ [@coach]
    end
  end

  context "donors" do
    before(:each) do
      @program = Fabricate(:program)
      @donor = Fabricate(:donor, :program => @program)
      @nondonor = Fabricate(:person, :program => @program)
    end

    it "returns donors only" do
      @program.donors.to_a.should =~ [@donor]
    end
  end

  context "alumni" do
    before(:each) do
      @program = Fabricate(:program)
      @alum = Fabricate(:alumnus, :program => @program)
      @nonalum = Fabricate(:person, :program => @program)
    end

    it "returns alumni only" do
      @program.alumni.to_a.should =~ [@alum]
    end
  end

  context "parents" do
    before(:each) do
      @program = Fabricate(:program)
      @parent = Fabricate(:parent, :program => @program)
      @nonparent = Fabricate(:person, :program => @program)
    end

    it "returns parents only" do
      @program.parents.to_a.should =~ [@parent]
    end
  end

  context "other" do
    before(:each) do
      @program = Fabricate(:program)
      @other = Fabricate(:person, :program => @program)
      @donor = Fabricate(:donor, :program => @program)
      @parent = Fabricate(:parent, :program => @program)
      @alum = Fabricate(:alumnus, :program => @program)
      @coach = Fabricate(:coach, :program => @program)
      @staff = Fabricate(:staff, :program => @program)
      @recruit = Fabricate(:recruit, :program => @program)
      @rostered_player = Fabricate(:rostered_player, :program => @program)
    end

    it "only returns others" do
      @program.others.to_a.should =~ [@other]
    end
  end
end
