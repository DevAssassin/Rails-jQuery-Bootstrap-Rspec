require "spec_helper"

module ScoutForce
  module Steak
    module AcceptanceFactory
      def create_recruit
        visit new_recruit_path

        fill_in 'person_first_name', :with => 'Phil'
        fill_in 'person_last_name', :with => 'Brabbs'
        fill_in 'person_nickname', :with => 'Dominator'
        fill_in 'person_address_attributes_street', :with => '123 Main St.'
        fill_in 'person_email', :with => 'phil@example.com'

        yield if block_given?

        click_button 'Save'
      end

      def create_coach
        visit new_coach_path

        fill_in 'person_first_name', :with => 'Lloyd'
        fill_in 'person_last_name', :with => 'Carr'
        check 'person_coach'

        yield if block_given?

        click_button 'Save'
      end

      def create_rostered_player
        visit new_rostered_player_path

        fill_in 'person_first_name', :with => 'Dernard'
        fill_in 'person_last_name', :with => 'Robinson'

        yield if block_given?

        click_button 'Save'
      end
    end

    module LoginHelper
      def log_in(options = {})
        Fabricate(:country, :name => "United States of America")
        Fabricate(:country, :name => "Canada")
        Fabricate(:country)

        @program = options[:program] || Fabricate(:program)
        @user = options[:user] || Fabricate(:user)
        @user.programs << @program
        @user.accounts << @program.account
        @user.default_scope = "Program|#{@program.id}"
        @user.save

        @account = @program.account

        visit new_user_session_path

        fill_in 'user_email', :with => @user.email
        fill_in 'user_password', :with => 'testtest'

        click_button 'Log in'
      end

      def log_out
        visit destroy_user_session_path
      end
    end

    module ScopeHelper
      def change_scope(account_or_program)
        visit change_scope_path(:scope => "#{account_or_program.class.to_s}|#{account_or_program.id}")
      end
    end
  end
end

RSpec.configure do |config|
  config.include ScoutForce::Steak::AcceptanceFactory, :type => :request
  config.include ScoutForce::Steak::LoginHelper, :type => :request
  config.include ScoutForce::Steak::ScopeHelper, :type => :request
end
