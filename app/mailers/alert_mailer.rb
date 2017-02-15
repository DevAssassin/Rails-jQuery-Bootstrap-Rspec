class AlertMailer < ActionMailer::Base
  layout 'email'

  default from: "athletics@scoutforce.com"

  def self.send_alerts(alerts)
    alerts.each do |alert|
      rule_violation(alert).deliver
    end
  end

  def rule_violation(alert)
    @alert = alert
    @violation = alert.caused_by

    subject = "[ScoutForce] Rule Violation for program #{alert.program.name}"
    to = alert.account.alert_subscribers.push(alert.user.email)

    mail to: to, subject: subject
  end
end
