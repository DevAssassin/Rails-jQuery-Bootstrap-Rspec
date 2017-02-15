require 'spec_helper'

describe User do
  context "and an account" do
    let(:user) { Fabricate(:user) }
    let(:account) { Fabricate(:account) }

    context "associating accounts" do
      it "sets by valid account_ids" do
        user.update_account_ids!([account.id.to_s])
        user.accounts.should include(account)
        account.reload
        account.users.should include(user)
      end

      it "ignores invalid account_ids" do
        user.update_account_ids!(["", account.id.to_s])
        user.accounts.should include(account)
        user.accounts.should have(1).account
        account.reload
        account.users.should include(user)
      end

      it "doesn't add accounts twice" do
        user.update_account_ids!([account.id.to_s])
        user.update_account_ids!([account.id.to_s])

        # TODO figure out why this doesn't work
        # user.accounts.should have(1).account
        user.accounts.size.should == 1
      end

      it "removes accounts if they're not present" do
        user.update_account_ids!([account.id.to_s])
        user.update_account_ids!([])
        user.reload
        account.reload

        user.accounts.should be_empty
        account.users.should be_empty
      end
    end

    context "that is associated" do
      before(:each) do
        user.accounts << account
      end

      it "sets the account" do
        user.accounts.should include(account)
      end

      context "finding scoped accounts" do
        before(:each) do
          @other_account = Fabricate(:account)
        end

        it "finds an account that the user has access to" do
          user.find_scoped_accounts(account.id).should == account
        end

        it "doesn't find an account that the user doesn't have access to" do
          other_account = Fabricate(:account)
          lambda {
            user.find_scoped_accounts(other_account.id)
          }.should raise_error(Mongoid::Errors::DocumentNotFound)
        end
      end


      context "and a program" do
        let(:program) { Fabricate(:program) }
        let!(:other_account_program) { Fabricate(:program, :account => account) }
        let!(:other_program) { Fabricate(:program) }

        context 'that is associated' do
          before(:each) do
            user.programs << program
          end

          it "adds the program" do
            user.programs.should include(program)
          end

          it "properly scopes associated in #find_scoped_programs" do
            user.find_scoped_programs(program.id).should == program
          end

          it "doesn't allow access to other programs in #find_scoped_programs" do
            lambda {
              user.find_scoped_programs(other_program.id)
            }.should raise_error(Mongoid::Errors::DocumentNotFound)
          end
        end

        context "associating programs" do
          it "sets by valid program_ids" do
            user.update_program_ids!([program.id.to_s])

            user.programs.should include(program)
            program.reload
            program.users.should include(user)
          end

          it "ignores invalid program_ids" do
            user.update_program_ids!(["", program.id.to_s])
            user.programs.should include(program)
            user.programs.size.should == 1
            program.reload
            program.users.should include(user)
          end

          it "doesn't add programs twice" do
            user.update_program_ids!([program.id.to_s])
            user.update_program_ids!([program.id.to_s])

            user.programs.size.should == 1
          end

          it "removes programs if they're not present" do
            user.update_program_ids!([program.id.to_s])
            user.update_program_ids!([])
            user.reload
            program.reload

            user.programs.should be_empty
            program.users.should be_empty
          end

          it "removes specified programs" do
            user.programs << program
            user.programs << other_account_program

            user.remove_program!(program)

            user.reload
            user.programs.should_not include(program)
            user.programs.should include(other_account_program)
            user.accounts.should include(account)
          end

          it "removes specified account, but not associated programs" do
            other_account = Fabricate(:account)
            user.accounts << other_account
            user.programs << other_account_program
            user.programs << other_program

            user.remove_account!(account)

            user.reload
            user.programs.should include(other_program)
            user.accounts.should include(other_account)
            user.programs.should include(other_account_program)
            user.accounts.should_not include(account)
          end
        end
      end

      context "a coached recruit"  do
        let(:recruit) { Fabricate(:recruit) }

        before(:each) do
          recruit.watchers << user
          recruit.save
        end

        it "shows up in the list of coached recruits" do
          user.coached_recruits.should include(recruit)
        end
      end
    end
  end

  context "when inviting new users" do
    let(:user) { Fabricate(:user) }
    let(:account) { Fabricate(:account) }
    let(:program) { Fabricate(:baseball_program, :account => account) }
    let(:program2) { Fabricate(:baseball_program, :account => account) }

    it "allows program invitations" do
      user.invite(:programs => [program])

      user.programs.should include(program)
      user.accounts.should_not include(account)
    end

    it "allows account invitations" do
      user.invite(:programs => [program], :account => account)

      user.programs.should include(program)
      user.accounts.should include(account)
    end

    it "allows inviting to multiple programs" do
      user.invite(:programs => [program,program2])

      user.programs.should include(program)
      user.programs.should include(program2)
    end

    it "allows inviting to account but no programs" do
      user.invite(:account => account)

      user.accounts.should include(account)
    end

    it "should add account to user if flag passed" do
      invite = Invitation.new(account, {
        :recipient_email => user.email,
        :recipient_first_name => user.first_name,
        :recipient_last_name => user.last_name,
        :recipient_account_level => "1"
      })
      User.create_and_send_invitation(invite)
      user.reload.accounts.should include(account)
    end

    it "should use current scope to determine program to add" do
      invite = Invitation.new(program, {
        :recipient_email => user.email,
        :recipient_first_name => user.first_name,
        :recipient_last_name => user.last_name
      })
      User.create_and_send_invitation(invite)
      user.reload.programs.should include(program)
    end

    it "should use current scope to determine available programs" do
      program3 = Fabricate(:soccer_program, :account => nil)
      invite = Invitation.new(account, {
        :recipient_email => user.email,
        :recipient_first_name => user.first_name,
        :recipient_last_name => user.last_name,
        :program_ids => [program.id.to_s,program2.id.to_s,program3.id.to_s]
      })
      User.create_and_send_invitation(invite)
      user.reload
      user.programs.should include(program)
      user.programs.should include(program2)
      user.programs.should_not include(program3)
    end

    it "doesn't overwrite user name when inviting to existing account" do
      current_name = user.name
      invite = Invitation.new(account, {
        :recipient_email => user.email,
        :recipient_first_name => "Test",
        :recipient_last_name => "NoName",
        :program_ids => [program.id,program2.id]
      })

      User.create_and_send_invitation(invite)

      user.reload.name.should == current_name
    end

    context "and re-sending invitations" do
      let(:other_account) { Fabricate(:account) }
      let(:other_account_program) { Fabricate(:program, :account => other_account) }
      before :each do
        user.accounts = [account, other_account]
        user.programs = [program, program2, other_account_program]
      end

      it "scopes re-sent invitations by account" do
        user.resend_invitations(account).should =~ [account, program, program2]
      end

      it "scopes re-sent invitations by account programs" do
        # Get rid of user-access to other_account, but keep other_account_program
        user.accounts = [other_account]
        user.resend_invitations(account).should =~ [program, program2]
      end

      it "scopes re-sent invitations by program" do
        user.resend_invitations(program).should == [program]
      end
    end
  end

  context "defaults" do
    it "should return first program as default scope" do
      user = Fabricate(:user)
      program = Fabricate(:baseball_program)
      user.programs << program
      user.default_scope.should == program
    end

    it "should return first account if no default program" do
      account = Fabricate(:account)
      user = Fabricate(:user,:accounts => [account])
      user.default_scope.should == account
    end
  end

  context "recruit boards on dashboard" do
    it "converts default_recruit_boards to hash of arrays" do
      user = Fabricate(:user, :program => Fabricate(:program))
      board = Fabricate(:recruit_board, :program => user.program)
      user.default_recruit_boards[user.program.id.to_s] = board.id
      user.recruit_boards.to_a.should == [board]
    end

    it "returns empty array by default" do
      user = Fabricate(:user, :program => Fabricate(:program))
      user.recruit_boards.should == []
    end

    it "returns default recruit board before other recruit boards" do
      user = Fabricate(:user,:program => Fabricate(:program))
      board1 = Fabricate(:recruit_board, :program => user.program)
      board2 = Fabricate(:recruit_board, :program => user.program)
      user.show_board_on_dashboard(board2)
      user.show_board_on_dashboard(board1)
      user.recruit_boards.to_a.should == [board2,board1]
      user.default_recruit_board = board1
      user.recruit_boards.to_a.should == [board1,board2]
    end
  end

  it "does not break when default board is deleted" do
    user = Fabricate(:user, :program => Fabricate(:program))
    user.default_recruit_board.should be_nil
    new_board = Fabricate(:recruit_board, :program => user.program)
    user.default_recruit_board = new_board
    user.default_recruit_board.should == new_board
    new_board.delete
    user.default_recruit_board.should be_nil
  end

  describe "permissions" do
    let(:account) { Fabricate(:basic_account) }
    let(:user) { Fabricate(:user, account: account) }
    let(:person) { Fabricate(:person, account: account) }

    context "on basic accounts" do
      it "doesn't allow SMS if it is disabled on the account" do
        user.can_sms?(person).should be_false
        user.can_sms?(person.class).should be_false
      end
    end

    context "on accounts with SMS" do
      let(:account) { Fabricate(:account_with_sms) }

      it "allows SMS if it is enabled on the account" do
        user.can_sms?(person).should be_true
        user.can_sms?(person.class).should be_true
      end

      context "on recruits" do
        let(:person) { Fabricate(:recruit) }

        it "doesn't allow SMS" do
          user.can_sms?(person).should be_false
          user.can_sms?(person.class).should be_false
        end
      end
    end

    context "on accounts with recruit SMS" do
      let(:account) { Fabricate(:account_with_recruit_sms) }
      let(:person) { Fabricate(:recruit) }

      it "allows users to SMS recruits" do
        user.can_sms?(person).should be_true
        user.can_sms?(person.class).should be_true
      end
    end
  end
end
