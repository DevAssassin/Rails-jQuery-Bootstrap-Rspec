require 'spec_helper'

describe RecruitBoard do
  before(:each) do
    @recruit1 = Fabricate(:baseball_recruit)
    @recruit2 = Fabricate(:baseball_recruit)
    @recruit3 = Fabricate(:baseball_recruit)
    @rb = Fabricate(:recruit_board)
  end

  context "with an empty board" do
    it "adds a recruit to the recruit board" do
      @rb.recruit_list = [@recruit1.id]

      @rb.recruits.should have(1).recruit
      @rb.recruits.first.should == @recruit1
    end

    it "pushes recruits to the end of the list" do
      @rb.push_recruit(@recruit1)

      @rb.recruits.should == [@recruit1]
    end

    it "works properly with string ids" do
      @rb.recruit_list = [@recruit1.id.to_s]

      @rb.recruits.should have(1).recruit
      @rb.recruits.first.should == @recruit1
    end
  end

  context "with a previously filled board" do
    it "replaces the board with the new values" do
      @rb.recruit_list = [@recruit3.id, @recruit1.id, @recruit2.id]
      @rb.recruit_list = [@recruit2.id, @recruit1.id]

      @rb.recruits.should have(2).recruits
      @rb.recruits.should == [@recruit2, @recruit1]
    end

    it "doesn't delete the old board if there is a problem" do
      @rb.recruit_list = [@recruit3.id, @recruit1.id, @recruit2.id]
      @rb.save

      lambda {
        @rb.recruit_list = nil
      }.should raise_error

      @rb.save
      @rb.reload

      @rb.recruits.should have(3).recruits
    end

    it "pushes recruits to the end of the list" do
      @rb.recruit_list = [@recruit2.id, @recruit1.id]

      @rb.push_recruit(@recruit3)

      @rb.recruits.should have(3).recruits
      @rb.recruits.last.should == @recruit3
    end

    it "doesn't push duplicates" do
      @rb.recruit_list = [@recruit2.id, @recruit1.id]

      @rb.push_recruit(@recruit2)
      @rb.recruits.should have(2).recruits
    end

    it "removes a recruit from the board" do
      @rb.recruit_list = [@recruit1.id, @recruit2.id, @recruit3.id]

      @rb.remove_recruit(@recruit2)

      @rb.recruits.should == [@recruit1, @recruit3]

      @rb.remove_recruit(@recruit1)

      @rb.recruits.should == [@recruit3]
    end

    it "won't fail if recruit list includes bad id" do
      @rb.recruit_list = [@recruit1.id, @recruit2.id, "abc123"]
      recruits = @rb.recruits
      recruits.count.should == 2
    end
  end

  context "default recruit boards" do
    before(:each) do
      @user = Fabricate(:admin)
      @program = @user.programs.first
      @user.program = @program
    end

    context "user and program without a board" do
      it "creates a new board" do
        board = @user.recruit_board

        board.program.should == @program
      end
    end

    context "user without a board, program with a board" do
      before(:each) do
        @board = Fabricate(:recruit_board)
        @program.recruit_boards << @board
      end

      it "returns the program's board" do
        board = @user.recruit_board

        board.should == @board
      end
    end

    context "user with a board" do
      before(:each) do
        @board = Fabricate(:recruit_board, :program => @program)
        @user.default_recruit_board = @board
        @user.save
      end

      it "returs the user's board" do
        @user.recruit_board.should == @board
      end

      it "works with other programs" do
        @user.program = Fabricate(:program)

        @user.recruit_board.should_not == @board
      end
    end
  end
end
