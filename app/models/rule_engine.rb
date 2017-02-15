class RuleEngine
  attr_accessor :interaction
  attr_reader :broken_rules, :alerts

  def initialize
    yield self if block_given?

    @broken_rules = []
    @alerts = []
  end

  def rules
    rules = program.phone_call_rules.
      for_time(interaction.interaction_time)

    if person.transfer_student?
      rules = rules.for_transfer_type(person.transfer_type)
    else
      rules = rules.without_transfer_type
      rules = rules.for_class(person.school_class(interaction.interaction_time))
    end

    rules.map do |rule|
      rule.interaction = interaction
      rule
    end
  end

  def can_interact?
    return true if unlimited?
    return true unless interaction.countable?
    return false if rules.blank?

    all_pass = rules.all? do |rule|
      success = rule.can_interact?

      if !success
        self.broken_rules << rule
      end

      success
    end

    all_pass
  end

  def interact!
    interactable = can_interact?

    return true if interactable

    alert_info = {
      person: interaction.person,
      user: interaction.user,
      subject: "Exceeded Phone Call Limit",
      caused_by: interaction
    }

    if broken_rules.empty?
      self.alerts << Interactions::Alert.create(alert_info.merge(
        details: "No rules allowing phone calls were defined for this period."
      ))
    else
      broken_rules.each do |rule|
        self.alerts << Interactions::Alert.create(alert_info.merge(
          details: rule.message
        ))
      end
    end

    false
  end

  def calls_remaining
    return -1 if unlimited?

    limited, unlimited = rules.map(&:calls_remaining).partition { |r| r >= 0 }

    if limited.present?
      limited.min
    elsif unlimited.present?
      -1
    else
      0
    end
  end

  def program
    interaction.program
  end

  def person
    interaction.person
  end

  def unlimited?
    person.nli_received?
  end
end
