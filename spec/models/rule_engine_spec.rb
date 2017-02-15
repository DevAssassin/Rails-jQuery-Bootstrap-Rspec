require 'spec_helper'

module RuleEngineMacros
  def it_has_no_rules
    it "has no rules apply" do
      engine.rules.should be_empty
    end
  end

  def it_matches_rules(&block)
    let(:__matched_rules, &block)

    it "matches rules" do
      engine.rules.should =~ __matched_rules
    end
  end

  def it_breaks_rules(&block)
    let(:__broken_rules, &block)

    it "breaks rules" do
      engine.can_interact?

      engine.broken_rules.should =~ __broken_rules
    end
  end

  def it_can_interact
    it "can interact" do
      engine.can_interact?.should be_true
    end
  end

  def it_cannot_interact
    it "cannot interact" do
      engine.can_interact?.should be_false
    end
  end
end

describe RuleEngine do
  extend RuleEngineMacros

  let(:program) { Fabricate(:program) }
  let(:person) { Fabricate(:baseball_recruit, program: program, graduation_year: '2014') }
  let(:interaction) {
    Fabricate.build(
      :phone_call_interaction,
      person: person,
      program: program,
      interaction_time: Time.parse('2011-01-15')
    )
  }
  let(:engine) do
    RuleEngine.new do |e|
      e.interaction = interaction
    end
  end

  context "with no rules" do
    let!(:rules) { [] }

    it_cannot_interact

    it "creates an alert if an interaction occurs" do
      engine.interact!

      person.interactions.last.should be_kind_of(Interactions::Alert)
    end

    it "allows uncountable interactions" do
      interaction.countable = false

      engine.can_interact?.should be_true
    end

    it "returns 0 calls available" do
      engine.calls_remaining.should == 0
    end
  end

  context "with a single rule in the program" do
    let!(:rules) do
      [
        Fabricate(:january_phone_call_rule, program: program),
        Fabricate(:january_phone_call_rule, program: Fabricate(:program)),
      ]
    end

    it "fetches the proper rules for the specified date" do
      valid_rule = rules.first
      rules = engine.rules

      rules.should =~ [valid_rule]
    end

    it "fetches no rules when the program doesn't match" do
      engine.interaction = Fabricate.build(:phone_call_interaction, interaction_time: Time.parse('2011-01-15'), program: Fabricate(:program))
      rules = engine.rules

      rules.should be_empty
    end

    context "when the recruit's school class doesn't match" do
      let(:person) { Fabricate(:recruit, graduation_year: '2015') }

      it_has_no_rules
    end

    context "when the recruit doesn't have a school class" do
      let(:person) { Fabricate(:recruit, graduation_year: nil) }

      it_has_no_rules
    end

    it "fetches no rules when the school class doesn't match" do
      engine.interaction = Fabricate.build(:phone_call_interaction, interaction_time: Time.parse('2010-01-15'), program: program)
      rules = engine.rules

      rules.should be_empty
    end

    it_can_interact

    it "allows interactions if there are uncountable interactions" do
      Fabricate(
        :phone_call_interaction,
        person: person,
        program: program,
        interaction_time: Time.parse('2011-01-14'),
        countable: false
      )

      engine.can_interact?.should be_true
    end

    it "returns 1 call available" do
      engine.calls_remaining.should == 1
    end

    it "returns most restrictive rule for calls_remaining" do
      Fabricate(:january_phone_call_rule, calls_allowed: '-1', program: program)

      engine.calls_remaining.should == 1
    end

    context "that is at its call limit" do
      let!(:other_interaction) {
        Fabricate(
          :phone_call_interaction,
          person: person,
          program: program,
          interaction_time: Time.parse('2011-01-14')
        )
      }

      it_cannot_interact

      it_breaks_rules { [rules.first] }

      it "creates an alert if an interaction occurs" do
        engine.interact!

        alert = person.interactions.last
        alert.should be_kind_of(Interactions::Alert)
        alert.details.should == rules.first.message
        alert.caused_by.should == interaction
      end
    end
  end

  context "with a transfer student" do
    let(:person) { Fabricate(:transfer_recruit, transfer_type: 'Two Year') }
    let(:rules) { [] }

    context "and a transfer student rule" do
      let!(:rules) do
        [
          Fabricate(:transfer_phone_call_rule, program: program),
          Fabricate(:january_phone_call_rule, program: program)
        ]
      end

      it "fetches the proper rule" do
        engine.rules.should =~ [rules.first]
      end

      context "that does not match" do
        let(:person) { Fabricate(:transfer_recruit, transfer_type: 'Prep') }

        it "fetches no rules" do
          engine.rules.should be_empty
        end
      end

      context "on a recruit without a transfer type" do
        let(:person) { Fabricate(:transfer_recruit, transfer_type: '') }

        it "fetches no rules" do
          engine.rules.should be_empty
        end
      end

      context "on high school students" do
        let(:person) { Fabricate(:baseball_recruit, graduation_year: 2014)}

        it "fetches the proper rules" do
          engine.rules.should =~ [rules.last]
        end
      end

      context "on unknown recruits" do
        let(:person) { Fabricate(:baseball_recruit) }

        it "fetches no rules" do
          engine.rules.should be_empty
        end
      end

      context "when the recruit has a graduation year" do
        before(:each) do
          person.graduation_year = '2012'
        end

        it_matches_rules { [rules.first] }
      end
    end
  end

  context "with a four-year transfer rule" do
    let!(:rules) {
      [Fabricate(:transfer_phone_call_rule, program: program, transfer_type: 'Four Year')]
    }

    context "and a recruit without a transfer release" do
      let(:person) { Fabricate(:transfer_recruit, transfer_type: 'Four Year')}

      it_cannot_interact
    end
  end

  context "with a recruit with a signed NLI" do
    let(:person) { Fabricate(:baseball_recruit, program: program, nli_received: true) }

    it_can_interact

    it "allows unlimited calls" do
      engine.calls_remaining.should == -1
    end
  end
end
