require 'spec_helper'

describe PhoneCallRule do
  before(:all) do
    @__old_zone = Time.zone
    Time.zone = "Istanbul"
  end

  after(:all) do
    Time.zone = @__old_zone
  end

  context "when finding rules in time ranges" do
    let!(:rule) { Fabricate(:phone_call_rule) }
    let!(:other_rule) { Fabricate(:february_phone_call_rule) }

    it "finds both rules in February" do
      rules = PhoneCallRule.for_time(Time.parse("2011-02-15")).to_a

      rules.should =~ [rule, other_rule]
    end

    it "finds only one rule in January" do
      rules = PhoneCallRule.for_time(Time.parse("2011-01-15")).to_a

      rules.should =~ [rule]
    end

    it "finds rules in Eastern time" do
      rules = PhoneCallRule.for_time(Time.parse("2011-01-01 00:00:00 EST")).to_a

      rules.should =~ [rule]
    end

    it "excludes rules that don't match eastern time" do
      rules = PhoneCallRule.for_time(Time.parse("2010-12-31 23:59:59 EST")).to_a

      rules.should be_empty
    end
  end

  context "when finding rules for transfer students" do
    let!(:rule) { Fabricate(:transfer_phone_call_rule) }
    let!(:other_rule) { Fabricate(:phone_call_rule) }

    it "finds rules for transfer students" do
      rules = PhoneCallRule.for_transfer_type('Two Year').to_a

      rules.should =~ [rule]
    end

    it "finds rules for others when transfer_type is nil" do
      PhoneCallRule.for_transfer_type(nil).to_a.should =~ [other_rule]
    end

    it "finds no rules when transfer_type is ''" do
      PhoneCallRule.for_transfer_type('').to_a.should be_empty
    end

    it "finds rules for others with #without_transfer_type" do
      PhoneCallRule.without_transfer_type.to_a.should =~ [other_rule]
    end
  end

  context "when evaluating rules on a clean person" do
    let(:person) { Fabricate(:baseball_recruit) }
    let(:time) { Time.parse("2011-01-15") }
    let(:interaction) { Fabricate.build(
      :phone_call_interaction,
      person: person,
      interaction_time: time
    )}

    it "allows calls during the time range" do
      rule = Fabricate(:january_phone_call_rule, interaction: interaction)

      rule.time_ok?.should be_true
      rule.can_interact?.should be_true
    end

    it "calculates the number of calls remaining" do
      rule = Fabricate(:january_phone_call_rule, interaction: interaction)

      rule.calls_remaining.should == 1
    end

    it "calculates the number of calls remaining for unlimited periods" do
      rule = Fabricate(:january_phone_call_rule, interaction: interaction, :calls_allowed => -1)

      rule.calls_remaining.should == -1
    end

    it "allows calls if the attempted interaction is the same as the evaluated one" do
      interaction.save
      rule = Fabricate(:january_phone_call_rule, interaction: interaction)

      rule.can_interact?.should be_true
    end

    it "doesn't allow calls outside of the time range" do
      interaction.interaction_time = Time.parse("2011-02-15")
      rule = Fabricate(:january_phone_call_rule, interaction: interaction)

      rule.time_ok?.should be_false
      rule.can_interact?.should be_false
    end

    it "doesn't allow calls if there are 0 calls allowed" do
      rule = Fabricate(
        :january_phone_call_rule, :calls_allowed => 0,
        interaction: interaction
      )

      rule.calls_allowed_ok?.should be_false
      rule.can_interact?.should be_false
    end

    it "allows lots of calls if there are unlimited calls allowed" do
      rule = Fabricate(
        :january_phone_call_rule, :calls_allowed => -1,
        interaction: interaction
      )

      rule.stub!(:calls_this_period).and_return(1000000)

      rule.calls_allowed_ok?.should be_true
      rule.can_interact?.should be_true
    end
  end

  context "when evaluating rules on a person who has been called during the rule period" do
    let(:person) { Fabricate(:baseball_recruit) }
    let(:time) { Time.parse("2011-01-15") }
    let(:rule) {
      Fabricate(
        :january_phone_call_rule, calls_allowed: 1,
        time_period: time_period, interaction: interaction
    )}
    let(:interaction) {
      Fabricate(
        :phone_call_interaction,
        interaction_time: time,
        person: person
      )
    }
    let(:interaction_time) { Time.parse("2011-01-05") }
    let!(:existing_interaction) {
      Fabricate(
        :phone_call_interaction,
        interaction_time: interaction_time,
        person: person
      )
    }

    context "for the day" do
      let(:interaction_time) { Time.parse("2011-01-15") }
      let(:time_period) { 'day' }

      context "if the interaction occurred on a different day" do
        let(:interaction_time) { Time.parse("2011-01-10") }

        it "allows interaction" do
          rule.can_interact?.should be_true
        end

        it "calculates one call remaining" do
          rule.calls_remaining.should == 1
        end
      end

      it "does not allow further interactions for the day" do
        rule.can_interact?.should be_false
      end

      it "calculates no calls remaining at interaction limit" do
        rule.calls_remaining.should == 0
      end

      it "calculates no calls remaining if over interaction limit" do
        interaction.dup.save

        rule.calls_remaining.should == 0
      end

      it "calculates unlimited calls remaining for unlimited rules" do
        rule = Fabricate(
          :january_phone_call_rule, calls_allowed: -1,
          time_period: time_period, interaction: interaction
        )

        rule.calls_remaining.should == -1
      end
    end

    context "for the week" do
      let(:interaction_time) { Time.parse('2011-01-05')}
      let(:time) { Time.parse('2011-01-06')}
      let(:time_period) { 'week' }

      it "allows if the interaction occurred in a different week" do
        rule.interaction.interaction_time = Time.parse("2011-01-20")
        rule.can_interact?.should be_true
      end

      it "does not allow further interactions for the week" do
        rule.can_interact?.should be_false
      end
    end

    context "for the month" do
      let(:rule) {
        Fabricate(
          :phone_call_rule, calls_allowed: 1,
          time_period: time_period, interaction: interaction
        )
      }

      let(:time_period) { 'month' }

      it "allows if the interaction occurred in a different month" do
        rule.interaction.interaction_time = Time.parse("2011-02-20")
        rule.can_interact?.should be_true
      end

      it "does not allow further interactions for the week" do
        rule.can_interact?.should be_false
      end
    end

    context "for the period" do
      let(:time_period) { 'period' }

      it "does not allow further interactions for the period" do
        rule.can_interact?.should be_false
      end
    end
  end

  context "when calculating period date ranges" do
    let(:interaction) { Fabricate(:phone_call_interaction) }

    it "returns the whole day for the period" do
      interaction.interaction_time = Time.parse("2011-01-05 13:00:00 EST")
      rule = Fabricate(:january_phone_call_rule, time_period: 'day', interaction: interaction)

      rule.period_date_range.should == (Time.parse("2011-01-05 00:00:00 EST")..Time.parse('2011-01-06 00:00:00 EST'))
    end

    it "returns the Sunday -> Saturday week for the period" do
      interaction.interaction_time = Time.parse("2011-01-05")
      rule = Fabricate(:january_phone_call_rule, time_period: 'week', interaction: interaction )

      rule.period_date_range.should == (Time.parse("2011-01-02 00:00:00 EST")..Time.parse('2011-01-09 00:00:00 EST'))
    end

    it "returns the month for the period" do
      interaction.interaction_time = Time.parse("2011-01-05")
      rule = Fabricate(:phone_call_rule, time_period: 'month', interaction: interaction )

      rule.period_date_range.should == (Time.parse("2011-01-01 00:00:00 EST")..Time.parse('2011-02-01 00:00:00 EST'))
    end

    it "returns the whole period for the period" do
      interaction.interaction_time = Time.parse("2011-01-05")
      rule = Fabricate(:phone_call_rule, time_period: 'period', interaction: interaction )

      rule.period_date_range.should == (Time.zone.parse("2011-01-01 00:00:00 EST")..Time.zone.parse('2011-03-01 00:00:00 EST'))
    end

    it "returns a truncated period" do
      interaction = Fabricate(
        :phone_call_interaction,
        interaction_time: Time.parse("2011-01-05 13:00:00 EST")
      )

      rule = Fabricate(
        :phone_call_rule, time_period: 'month',
        start_time: Time.parse("2011-01-05 00:00:00 EST"),
        end_time: Time.parse("2011-01-20 00:00:00 EST"),
        interaction: interaction
      )

      rule.period_date_range.should == (Time.parse("2011-01-05 00:00:00 EST")..Time.parse('2011-01-20 00:00:00 EST'))
    end
  end

  context "when finding rules for a particular school class" do
    let!(:frosh_rule) { Fabricate(:freshman_phone_call_rule) }
    let!(:soph_rule) { Fabricate(:sophomore_phone_call_rule) }
    let!(:junior_rule) { Fabricate(:junior_phone_call_rule) }
    let!(:senior_rule) { Fabricate(:senior_phone_call_rule) }
    let!(:yearless_rule) { Fabricate(:phone_call_rule, school_class: nil) }

    it { PhoneCallRule.for_class(:freshman).to_a.should =~ [frosh_rule]}
    it { PhoneCallRule.for_class(:sophomore).to_a.should =~ [soph_rule]}
    it { PhoneCallRule.for_class(:junior).to_a.should =~ [junior_rule]}
    it { PhoneCallRule.for_class(:senior).to_a.should =~ [senior_rule]}
    it { PhoneCallRule.for_class(nil).to_a.should =~ [yearless_rule] }
  end

  context "when evaluating transfer student rules" do
    let(:program) { Fabricate(:program) }
    let!(:two_year_rule) { Fabricate(:two_year_phone_call_rule, interaction: interaction) }
    let!(:four_year_rule) { Fabricate(:four_year_phone_call_rule, interaction: interaction) }
    let!(:prep_rule) { Fabricate(:prep_phone_call_rule, interaction: interaction) }

    let(:four_year_recruit) { Fabricate(:transfer_recruit, transfer_type: 'Four Year', program: program) }
    let(:prep_recruit) { Fabricate(:transfer_recruit, transfer_type: 'Prep', program: program) }

    let(:interaction) { Fabricate.build(:phone_call_interaction, interaction_time: interaction_time, person: person) }
    let(:interaction_time) { Time.parse("2011-01-15 00:00:00 UTC") }

    context "on two-year transfer students" do
      let(:person) { Fabricate(:transfer_recruit, transfer_type: 'Two Year', program: program) }

      it "allows calls within the rule" do
        two_year_rule.can_interact?.should be_true
      end
    end

    context "on four-year transfer students" do
      let(:person) { Fabricate(:transfer_recruit, transfer_type: 'Four Year', program: program) }

      it "allows calls if transfer authorization has been received" do
        person.transfer_release_letter = true

        four_year_rule.can_interact?.should be_true
      end

      it "doesn't allow calls if transfer authorization hasn't been received" do
        person.transfer_release_letter = false

        four_year_rule.can_interact?.should be_false
      end
    end

    context "on prep students" do
      let(:person) { Fabricate(:transfer_recruit, transfer_type: 'Prep', program: program) }

      it "allows calls within the rule" do
        prep_rule.can_interact?.should be_true
      end
    end
  end

  context "#school_class=" do
    it "nils it if blank" do
      rule = Fabricate(:phone_call_rule)

      rule.school_class = ""
      rule.save

      rule.reload
      rule.school_class.should be_nil
    end
  end

  context "#transfer_type=" do
    it "nils it if blank" do
      rule = Fabricate(:phone_call_rule)

      rule.transfer_type = ""
      rule.save

      rule.reload
      rule.transfer_type.should be_nil
    end
  end
  # TODO Add specs to make sure time zones work as expected
  # ie: beginning_of_day/beginning_of_week use the proper time zone
end
